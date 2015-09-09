//
//  JSONSerializer.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class JSONSerializer: NSObject, RKSerialization {
    
    static func objectFromData(data: NSData!, error: NSErrorPointer) -> AnyObject! {
        
        let responseObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: error)
        
        // Check if we have any alerts to register
        if let responseObject = responseObject as? [String : AnyObject],
            alerts = responseObject["alerts"] as? [[String : AnyObject]] {
                let parsedAlerts = JSONSerializer.parseAlerts(alerts)
                if parsedAlerts.count > 0 {
                    AlertManager.sharedInstance.registerAlerts(parsedAlerts)
                }
        }
        
        return responseObject
    }
    
    static func dataFromObject(object: AnyObject!, error: NSErrorPointer) -> NSData! {
        return NSJSONSerialization.dataWithJSONObject(object, options: nil, error: error)
    }
    
    // Class function for parsing alerts
    private class func parseAlerts(alerts: [[String : AnyObject]]) -> [Alert] {
        var parsedAlerts: [Alert] = []
        for alert in alerts {
            if let configuredAlert = Alert.configuredAlert(alert) {
                parsedAlerts.append(configuredAlert)
            }
        }
        
        return parsedAlerts
    }
}