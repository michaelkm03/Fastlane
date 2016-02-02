//
//  VDeviceCapability.swift
//  victorious
//
//  Created by Vincent Ho on 1/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

enum DeviceType {
    case iPod
    case iPhone
    case iPad
    case Other
}

@objc enum VDeviceRating: Int{
    case Unknown = 0,
    Bad,
    NotGreat,
    Average,
    Fast,
    LightningFast
}

private let kiPodConstant = "iPod"
private let kiPadConstant = "iPad"
private let kiPhoneConstant = "iPhone"


extension UIDevice {
    func v_numberOfConcurrentAnimationsSupported() -> VDeviceRating {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        var identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        if identifier.hasPrefix(kiPodConstant) {
            identifier = identifier.stringByReplacingOccurrencesOfString(kiPodConstant, withString: "")
            identifier = identifier.componentsSeparatedByString(",")[0]
            let version: Int? = Int(identifier)
            if let _ = version {
                if version >= 7 {
                    return VDeviceRating.Average
                }
                else {
                    return VDeviceRating.Bad
                }
            }
        }
        else if identifier.hasPrefix(kiPadConstant) {
            identifier = identifier.stringByReplacingOccurrencesOfString(kiPadConstant, withString: "")
            identifier = identifier.componentsSeparatedByString(",")[0]
            let version: Int? = Int(identifier)
            if let _ = version {
                if version >= 5 {
                    return VDeviceRating.Fast
                }
                else {
                    return VDeviceRating.Average
                }
            }
        }
        else if identifier.hasPrefix(kiPhoneConstant) {
            identifier = identifier.stringByReplacingOccurrencesOfString(kiPhoneConstant, withString: "")
            identifier = identifier.componentsSeparatedByString(",")[0]
            let version: Int? = Int(identifier)
            if let _ = version {
                if version >= 7 {
                    return VDeviceRating.LightningFast
                }
                else if version >= 5 {
                    return VDeviceRating.Fast
                }
                else {
                    return VDeviceRating.Bad
                }
            }
        }
        //Other, return 0
        return VDeviceRating.Unknown
    }
}