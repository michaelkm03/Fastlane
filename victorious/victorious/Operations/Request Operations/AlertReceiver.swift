//
//  AlertReceiver.swift
//  victorious
//
//  Created by Patrick Lynch on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Defines an object that can receive an array of Alert values when parsed
/// from a network request and handle notifying the user.
protocol AlertReceiver {
    func onAlertsReceived( alerts: [Alert] )
}

class AlertReceiverSelector: NSObject {
    
    class var defaultReceiver: AlertReceiver {
        return InterstitialManager.sharedInstance
    }
}
