//
//  ViewController.swift
//  TestDeviceWallpapers
//
//  Created by David Smith on 4/16/18.
//Copyright 2018 David Smith
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import UIKit
import HealthKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if WCSession.default.isPaired {
            WatchDevice.lastSample { (size, model, software) in
                DispatchQueue.main.async {
                    self.watchButton.isHidden = false
                    self.watchLabel.text = "\(size)\n\(model)\n\(software)\n"
                }
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let platform   = iPhoneDevice.displayPlatform()
        let iOS        = iPhoneDevice.iOSVersion()
        let resolution = iPhoneDevice.resolution()

        self.deviceLabel.text = "\(platform)\n\(iOS)\n\(resolution)\n"
        
        WCSession.default.delegate = self
        WCSession.default.activate()

        
    }

    @IBOutlet weak var watchLabel: UILabel!
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var watchButton: UIButton!
    @IBAction func generateWatchWallpaper(_ sender: Any) {
        WatchDevice.lastSample { (size, model, software) in

            let screenSize = size == "38mm" ? CGSize(width: 272, height: 340) : CGSize(width: 312, height: 390 )
            let rect = CGRect(origin: .zero, size: screenSize)
            UIGraphicsBeginImageContextWithOptions(rect.size, false, 2.0)
            UIColor.black.setFill()
            UIRectFill(rect)
            
            var yOffset:CGFloat = 0
            let xOffset = screenSize.width * 0.05

            let attributes = [
                NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 34),
                NSAttributedStringKey.foregroundColor : UIColor.white
            ]
            
            let sizeSize = size.size(withAttributes: attributes)
            size.draw(at:CGPoint(x: xOffset, y: yOffset), withAttributes:attributes)
            yOffset += sizeSize.height * 1

            let modelSize = model.size(withAttributes: attributes)
            model.draw(at:CGPoint(x: xOffset, y: yOffset), withAttributes:attributes)
            yOffset += modelSize.height * 1

            let softwareSize = software.size(withAttributes: attributes)
            software.draw(at: CGPoint(x:xOffset, y: yOffset), withAttributes:attributes)
            yOffset += softwareSize.height * 1.2
            
            let paired   = "paired to"
            let pairedSize = paired.size(withAttributes: attributes)
            paired.draw(at:CGPoint(x: xOffset, y: yOffset), withAttributes:attributes)
            yOffset += pairedSize.height * 1

            let platform   = iPhoneDevice.displayPlatform()
            let platformSize = platform.size(withAttributes: attributes)
            platform.draw(at:CGPoint(x: xOffset, y: yOffset), withAttributes:attributes)
            yOffset += platformSize.height * 1

            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let cgImage = image?.cgImage {
                let uiImage = UIImage.init(cgImage: cgImage)
                UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }

        }
    }
    
    @IBAction func generateiPhoneWallpaper(_ sender: Any) {

        let screenSize = UIScreen.main.bounds.size
        let rect = CGRect(origin: .zero, size: screenSize)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        UIColor.black.setFill()
        UIRectFill(rect)
        
        var yOffset = screenSize.height * 0.4
        
        let attributes = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 48),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        
        let platform   = iPhoneDevice.displayPlatform()
        let platformSize = platform.size(withAttributes: attributes)
        platform.draw(at:CGPoint(x: screenSize.width / 2.0 - platformSize.width / 2.0, y: yOffset), withAttributes:attributes)
        yOffset += platformSize.height * 1.2
        
        let iOS        = iPhoneDevice.iOSVersion()
        let iOSSize = iOS.size(withAttributes: attributes)
        iOS.draw(at:CGPoint(x: screenSize.width / 2.0 - iOSSize.width / 2.0, y: yOffset), withAttributes:attributes)
        yOffset += iOSSize.height * 1.2
        
        let resolution = iPhoneDevice.resolution()
        let resolutionSize = resolution.size(withAttributes: attributes)
        resolution.draw(at:CGPoint(x: screenSize.width / 2.0 - resolutionSize.width / 2.0, y: yOffset), withAttributes:attributes)
        yOffset += resolutionSize.height * 1.2

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let cgImage = image?.cgImage {
            let uiImage = UIImage.init(cgImage: cgImage)
            UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        

    }
    
 
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your wallpaper has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
}

class WatchDevice {

    static func displaySize(_ hardwareVersion:String?) -> String {
        let sizeLookups = [
            "Watch1,1" : "38mm",
            "Watch1,2" : "42mm",
            "Watch2,3" : "38mm",
            "Watch2,4" : "42mm",
            "Watch2,6" : "38mm",
            "Watch2,7" : "42mm",
            "Watch3,1" : "38mm",
            "Watch3,2" : "42mm",
            "Watch3,3" : "38mm",
            "Watch3,4" : "42mm",
            ]
        
        if let version = hardwareVersion, let size = sizeLookups[version]  {
            return size
        } else {
            return "?"
        }
    }
    
    static func displayModel(_ hardwareVersion:String?) -> String {
        let modelLookups = [
            "Watch1,1" : "Series 0",
            "Watch1,2" : "Series 0",
            "Watch2,3" : "Series 2",
            "Watch2,4" : "Series 2",
            "Watch2,6" : "Series 1",
            "Watch2,7" : "Series 1",
            "Watch3,1" : "Series 3",
            "Watch3,2" : "Series 3",
            "Watch3,3" : "Series 3",
            "Watch3,4" : "Series 3",
            ]
        
        if let version = hardwareVersion, let model = modelLookups[version]  {
            return model
        } else {
            return "?"
        }
    }
    
    static func displaySoftwareVersion(_ softwareVersion:String?) -> String {
        if let version = softwareVersion {
            return "watchOS \(version)"
        } else {
            return "?"
        }
    }
    
    static let healthStore = HKHealthStore()
    
    static func lastSample( completion:@escaping ((_ size:String, _ model:String,_ watchOS:String) -> ()) ) {

        let type = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        
        healthStore.requestAuthorization(toShare: nil, read: [type]) { (success, error) in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { (query, samples, error) in
                if let safeSamples = samples, let sample = safeSamples.first as? HKQuantitySample {
                    
                    guard let device = sample.device else {
                        completion("?","?","?")
                        return
                    }
                    
                    let watchSoftware = displaySoftwareVersion(device.softwareVersion)
                    let size = displaySize(device.hardwareVersion)
                    let model = displayModel(device.hardwareVersion)
                    completion(size, model, watchSoftware)
                }
            }
            self.healthStore.execute(query)
        }
        
    }
}

class iPhoneDevice {
    
    static func resolution() -> String {
        let size = UIScreen.main.bounds
        return "\(Int(size.width))x\(Int(size.height))"
    }

    static func scale() -> String {
        let scale = UIScreen.main.scale
        return "\(Int(scale))x"
    }

    static func iOSVersion() -> String {
        let device = UIDevice.current.systemVersion
        return "iOS \(device)"
    }
    
    static func platform() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0,  count: size)
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        return String(cString: machine)
    }
    
    static func displayPlatform() -> String {
        let lookup = [
            "iPhone1,1" : "iPhone 1G",
            "iPhone1,2" :"iPhone 3G",
            "iPhone2,1" :"iPhone 3GS",
            "iPhone3,1" :"iPhone 4",
            "iPhone3,2" :"iPhone 4",
            "iPhone3,3" :"iPhone 4",
            "iPhone4,1" :"iPhone 4S",
            "iPhone5,1" :"iPhone 5",
            "iPhone5,2" :"iPhone 5",
            "iPhone5,3" :"iPhone 5c",
            "iPhone5,4" :"iPhone 5c",
            "iPhone6,1" :"iPhone 5s",
            "iPhone6,2" :"iPhone 5s",
            "iPhone6,3" :"iPhone 5s",
            "iPhone7,1" :"iPhone 6+",
            "iPhone7,2" :"iPhone 6",
            "iPhone8,1" :"iPhone 6s",
            "iPhone8,2" :"iPhone 6s+",
            "iPhone8,4" :"iPhone se",
            "iPhone9,1" :"iPhone 7",
            "iPhone9,2" :"iPhone 7+",
            "iPhone9,3" :"iPhone 7",
            "iPhone9,4" :"iPhone 7+",
            "iPhone10,1" :"iPhone 8",
            "iPhone10,4" :"iPhone 8",
            "iPhone10,2" :"iPhone 8+",
            "iPhone10,5" :"iPhone 8+",
            "iPhone10,3" :"iPhone X",
            "iPhone10,6" :"iPhone X",

            "iPod1,1" :"iPod touch 1G",
            "iPod2,1" :"iPod touch 2G",
            "iPod3,1" :"iPod touch 3G",
            "iPod4,1" :"iPod touch 4G",
            "iPod5,1" :"iPod touch 5G",
            "iPod7,1" :"iPod touch 6G",
            
            "iPad1,1" :"iPad 1G",
            "iPad2,1" :"iPad 2G",
            "iPad2,2" :"iPad 2G",
            "iPad2,3" :"iPad 2G",
            "iPad2,4" :"iPad 2G",
            "iPad2,5" :"iPad Mini",
            "iPad2,6" :"iPad Mini",
            "iPad2,7" :"iPad Mini",
            "iPad3,1" :"iPad 3G",
            "iPad3,2" :"iPad 3G",
            "iPad3,3" :"iPad 3G",
            "iPad3,4" :"iPad 4G",
            "iPad3,5" :"iPad 4G",
            "iPad3,6" :"iPad 4G",
            "iPad4,1" :"iPad Air",
            "iPad4,2" :"iPad Air",
            "iPad4,3" :"iPad Air",
            "iPad4,4" :"iPad Mini 2",
            "iPad4,5" :"iPad Mini 2",
            "iPad4,6" :"iPad Mini 2",
            "iPad4,7" :"iPad Mini 3",
            "iPad4,8" :"iPad Mini 3",
            "iPad4,9" :"iPad Mini 3",
            "iPad5,3" :"iPad Air 2",
            "iPad5,2" :"iPad Mini 4",
            "iPad5,4" :"iPad Air 2",
            "iPad5,5" :"iPad Air 2",
            "iPad5,1" :"iPad Mini 4",
            "iPad5,6" :"iPad Air 2",
            "iPad6,3" :"iPad Pro",
            "iPad6,4" :"iPad Pro",
            "iPad6,7" :"iPad+ Pro",
            "iPad6,8" :"iPad+ Pro",
            "iPad6,11" :"iPad 5",
            "iPad6,12" :"iPad 5",
            "iPad7,5" :"iPad Pro 2",
            "iPad7,3" :"iPad Pro 2",
            "iPad7,4" :"iPad Pro 2",
            "iPad7,1" :"iPad+ Pro 2",
            "iPad7,2" :"iPad+ Pro 2",
        ]
        let platform = iPhoneDevice.platform()
        if let displayName = lookup[platform] {
            return displayName
        } else {
            return platform
        }
    }
    
}
