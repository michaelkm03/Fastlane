//
//  Alert.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

protocol AlertConfiguration {
    func configureWithInfo(info: [String : AnyObject])
}

enum AlertType : String {
    case LevelUp = ""
}

class Alert: AlertConfiguration, Hashable {
    
    let remoteID: String
    
    init(id: String) {
        remoteID = id
    }
    
    class func configuredAlert(info: [String : AnyObject]) -> Alert? {
        var alert: Alert?
        if let type = info["type"] as? String, id = info["id"] as? String {
            if type == AlertType.LevelUp.rawValue {
                alert = LevelUpAlert(id: id)
            }
        }
        alert?.configureWithInfo(info)
        return alert
    }
    
    /// MARK: AlertConfiguration
    
    func configureWithInfo(info: [String : AnyObject]) {
        // Subclasses should implement to set correct info
    }
    
    /// MARK: Hashable
    
    var hashValue: Int {
        if let remoteID = remoteID.toInt() {
            return remoteID
        }
        return 0
    }
}

func ==(lhs: Alert, rhs: Alert) -> Bool {
    return lhs.remoteID == rhs.remoteID
}

class LevelUpAlert: Alert {
    
    var level: String?
    var title: String?
    var description: String?
    var icons: [String]?
    var videoURL: String?
    
    /// MARK: AlertConfiguration
    
    override func configureWithInfo(info: [String : AnyObject]) {
        
    }
}