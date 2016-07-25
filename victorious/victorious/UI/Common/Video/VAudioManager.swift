//
//  VAudioManager.swift
//  victorious
//
//  Created by Patrick Lynch on 10/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import AVFoundation

/// An object that manages the propery system audio settings for a video player,
/// accessible through its singleton instance (see `sharedInstance`).
@objc class VAudioManager: NSObject {
    private static var instance: VAudioManager?
    
    class func sharedInstance() -> VAudioManager {
        if let instance = VAudioManager.instance {
            return instance
        }
        else {
            let newInstance = VAudioManager()
            VAudioManager.instance = newInstance
            return newInstance
        }
    }
    
    func setAudioSessionCategory(category: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory( category )
        }
        catch {
            print( "Error setting AVAudioSession's category to \(category): \(error)" )
        }
    }
}
