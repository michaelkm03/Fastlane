//
//  UIDevice+UUID.swift
//  victorious
//
//  Created by Patrick Lynch on 4/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UIDevice {
    
    /// Retreives a unique device ID using a method that is appropriate to the target architecture.
    /// This value remains constant when running in the iOS Simulator much as it would on a device.
    /// This allows stored login to work as expected in the simulator.
    var v_authorizationDeviceID: String {
        
        // If running on the simulator...
        #if(arch(i386) || arch(x86_64)) && os(iOS)
            let key = "com.getvictorious.debug-simulatedDeviceID"
            if let identifier = NSUserDefaults.standardUserDefaults().valueForKey(key) as? String {
                return identifier
            } else {
                let identifier = NSUUID().UUIDString
                NSUserDefaults.standardUserDefaults().setValue(identifier, forKey: key)
                NSUserDefaults.standardUserDefaults().synchronize()
                return identifier
            }
        #else
            return identifierForVendor?.uuidString ?? ""
        #endif
    }
}
