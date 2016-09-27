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
    case other
}


/*
 *
 *        Device                  Processor (Ghz, Type, Cores)    RAM                 Version                 Device Rating
 *
 *        -iPhone-
 *        iPhone 5                1.3 Ghz A6 (2)                  1GB                 5                       Decent
 *        iPhone 5C               1.3 Ghz A6 (2)                  1GB                 5                       Decent
 *        iPhone 5S               1.3 Ghz A7 (2)                  1GB                 6                       Average
 *        iPhone 6                1.4 Ghz A8 (2)                  1GB                 7                       Fast
 *        iPhone 6+               1.4 Ghz A8 (2)                  1GB                 7                       Fast
 *        iPhone 6S               1.85 Ghz A9 (2)                 2GB                 8                       Lightning Fast
 *        iPhone 6S+              1.85 Ghz A9 (2)                 2GB                 8                       Lightning Fast
 *        iPhone 7 (and onwards)  ...                             ...                 >8                      Lightning Fast
 *
 *
 *        -iPod Touch-
 *        iPod Touch 5G           1.0 Ghz A5 (2)                  512 MB              5                       Slow
 *        iPod Touch 6G           1.4 Ghz A8 (2)                  1 GB                6                       Average
 *        iPod Touch 7G (and onwards)...                          ...                 >6                      Fast
 *
 *
 *        -iPad (Regular, Mini, Pro)-
 *        iPad 2nd Gen            1.0 Ghz A5 (2)                  512 MB              2                       Slow
 *        iPad Mini 1             1.0 Ghz A5 (2)                  512 MB              2                       Slow
 *        iPad 3rd Gen            1.0 Ghz A5X (2)                 1 GB                3                       Decent
 *        iPad 4th Gen            1.4 Ghz A6X (2)                 1 GB                3                       Decent
 *        iPad Air                1.4 Ghz A7 (2)                  1 GB                4                       Average
 *        iPad Mini 2             1.3 Ghz A7 (2)                  1 GB                4                       Average
 *        iPad Mini 3             1.3 Ghz A7 (2)                  1 GB                4                       Average
 *        iPad Air 2              1.5 Ghz A8X (3)                 2 GB                5                       Lightning Fast
 *        iPad Mini 4             1.5 Ghz A8 (2)                  2 GB                5                       Fast
 *        iPad Pro                2.26 Ghz A9X (2)                4 GB                6                       Lightning Fast
 *
 */

@objc enum VDeviceRating: Int {
    case unknown = 1,
    slow = 3,
    decent = 5,
    average = 8,
    great = 13,
    fast = 15,
    lightningFast = 25
}

private let kiPodConstant = "iPod"
private let kiPadConstant = "iPad"
private let kiPhoneConstant = "iPhone"


extension UIDevice {
    func v_numberOfConcurrentAnimationsSupported() -> VDeviceRating {
        
        // This detects the iOS simulator
        #if(arch(i386) || arch(x86_64)) && os(iOS)
            return VDeviceRating.LightningFast
        
        #else
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        var identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        if identifier.hasPrefix(kiPodConstant) {
            identifier = identifier.replacingOccurrences(of: kiPodConstant, with: "")
            identifier = identifier.components(separatedBy: ",")[0]
            if let version = Int(identifier) {
                switch version {
                case 5:
                    return VDeviceRating.slow
                case 6:
                    return VDeviceRating.average
                case 6..<Int.max:
                    return VDeviceRating.fast
                default:
                    return VDeviceRating.unknown
                }
            }
        }
        else if identifier.hasPrefix(kiPadConstant) {
            identifier = identifier.replacingOccurrences(of: kiPadConstant, with: "")
            identifier = identifier.components(separatedBy: ",")[0]
            if let version = Int(identifier) {
                switch version {
                case 2:
                    return VDeviceRating.slow
                case 3:
                    return VDeviceRating.decent
                case 4:
                    return VDeviceRating.average
                case 5:
                    return VDeviceRating.fast
                case 6..<Int.max:
                    return VDeviceRating.lightningFast
                default:
                    return VDeviceRating.unknown
                }
            }
        }
        else if identifier.hasPrefix(kiPhoneConstant) {
            identifier = identifier.replacingOccurrences(of: kiPhoneConstant, with: "")
            identifier = identifier.components(separatedBy: ",")[0]
            if let version = Int(identifier) {
                switch version {
                case 5:
                    return VDeviceRating.decent
                case 6:
                    return VDeviceRating.average
                case 7:
                    return VDeviceRating.fast
                case 8..<Int.max:
                    return VDeviceRating.lightningFast
                default:
                    return VDeviceRating.unknown
                }
            }
        }
        //Other, return 1
        return VDeviceRating.unknown
        #endif
    }
}
