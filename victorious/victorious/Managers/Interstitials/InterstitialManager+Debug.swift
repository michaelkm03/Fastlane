//
//  InterstitialManager+Debug.swift
//  victorious
//
//  Created by Patrick Lynch on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension InterstitialManager {
    
    /// Registers a test "level" alert for testing interstitials
    func debug_registerTestLevelUpAlert() {
        #if V_SHOW_TEST_ALERT_SETTINGS
            self.disabled = true
            let params = ["type": "levelUp", "params" : ["user" : ["fanloyalty" : ["level" : 5, "tier" : "Bronze", "name" : "Level 5", "progress" : 70]], "title" : "Congrats", "description" : "You won some new stuff", "icons" : ["http://i.imgur.com/ietHgk6.png"], "backgroundVideo" : "http://media-dev-public.s3-website-us-west-1.amazonaws.com/b918ccb92d5040f754e70187baf5a765/playlist.m3u8"]]
            
            if let addtionalParameters = params["params"] as? [String : AnyObject],
                let type = params["type"] as? String {
                    AlertCreateOperation(type: type, addtionalParameters: addtionalParameters).queue() { results, error, cancelled in
                        self.disabled = false
                    }
            }
        #endif
    }
    
    /// Registers a test "achievement" alert for testing interstitials
    func debug_registerTestAchievementAlert() {
        #if V_SHOW_TEST_ALERT_SETTINGS
            self.disabled = true
            let params = ["type": "achievement",
                          "params": ["user": ["fanloyalty": ["level": 5, "tier": "Gold", "name": "Level 5", "progress": 70]],
                            "title": "Congrats",
                            "description": "Thanks for creating your first text post!",
                            "icons": ["http://i.imgur.com/ietHgk6.png"]]]
            
            if let addtionalParameters = params["params"] as? [String : AnyObject],
                let type = params["type"] as? String {
                    AlertCreateOperation(type: type, addtionalParameters: addtionalParameters).queue() { results, error, cancelled in
                        self.disabled = false
                    }
            }
            
        #endif
    }
    
    func debug_registerTestStatusUpdateAlert() {
        #if V_SHOW_TEST_ALERT_SETTINGS
            self.disabled = true
            let params = ["type": "statusUpdate",
                          "params": [
                            "user": ["fanloyalty": ["level": 5, "tier": "Gold", "name": "Level 5", "progress": 70]],
                            "title": "You are golden!",
                            "description": "You status has been upgraded to gold",
                            "icons": ["http://i.imgur.com/ietHgk6.png"]]]
            
            if let addtionalParameters = params["params"] as? [String : AnyObject],
                let type = params["type"] as? String {
                AlertCreateOperation(type: type, addtionalParameters: addtionalParameters).queue() { results, error, cancelled in
                    self.disabled = false
                }
            }
        #endif
    }
}
