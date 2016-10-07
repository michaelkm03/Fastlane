//
//  InterstitialManager+Debug.swift
//  victorious
//
//  Created by Patrick Lynch on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

extension InterstitialManager {
    
    /// Registers a test "achievement" alert for testing interstitials
    func debug_registerTestAchievementAlert() {
        #if V_SHOW_TEST_ALERT_SETTINGS
            self.disabled = true
            let params: [String: Any] = [
                "type": "achievement",
                "params": [
                    "user": ["fanloyalty": ["level": 5, "tier": "Gold", "name": "Level 5", "progress": 70]],
                    "title": "Congrats",
                    "description": "Thanks for creating your first text post!",
                    "icons": ["http://i.imgur.com/ietHgk6.png"]
                ]
            ]
            
            if let additionalParameters = params["params"] as? [String : AnyObject], let type = params["type"] as? String {
                RequestOperation(request: CreateAlertRequest(type: type, additionalParameters: additionalParameters)).queue { _ in
                    self.disabled = false
                }
            }
            
        #endif
    }
    
    func debug_registerTestStatusUpdateAlert() {
        #if V_SHOW_TEST_ALERT_SETTINGS
            self.disabled = true
            let params: [String: Any] = ["type": "statusUpdate",
                          "params": [
                            "user": ["fanloyalty": ["level": 5, "tier": "Gold", "name": "Level 5", "progress": 70]],
                            "title": "You are golden!",
                            "description": "You status has been upgraded to gold",
                            "icons": ["http://i.imgur.com/ietHgk6.png"]]]
            
            if let additionalParameters = params["params"] as? [String : AnyObject],
                let type = params["type"] as? String {
                RequestOperation(request: CreateAlertRequest(type: type, additionalParameters: additionalParameters)).queue { _ in
                    self.disabled = false
                }
            }
        #endif
    }
    
    func debug_registerTestToastAlert() {
        #if V_SHOW_TEST_ALERT_SETTINGS
            self.disabled = true
            let params: [String: Any] = ["type": "toast",
                          "params": [
                            "user": ["fanloyalty": ["level": 5, "tier": "Gold", "name": "Level 5", "progress": 70]],
                            "title": "You are a photographer! Keep posting cool photos to share with the community!",
//                            "description" : "You have earned a new photographer badge",
//                            "icons" : ["http://i.imgur.com/ietHgk6.png"]
                ]]
            if let additionalParameters = params["params"] as? [String : AnyObject],
                let type = params["type"] as? String {
                RequestOperation(request: CreateAlertRequest(type: type, additionalParameters: additionalParameters)).queue { _ in
                    self.disabled = false
                }
            }
        #endif
    }
}
