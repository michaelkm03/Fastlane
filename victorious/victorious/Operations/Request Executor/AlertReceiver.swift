//
//  AlertReceiver.swift
//  victorious
//
//  Created by Patrick Lynch on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Defines an object that can receive Alert values when parsed from a network request or
/// created on the fly by other parts of the app and handles notifying the user.
protocol AlertReceiver {
    func receive(alert: Alert)
    func receive(alerts: [Alert])
}

class AlertReceiverSelector: NSObject {
    class var defaultReceiver: AlertReceiver {
        return InterstitialManager.sharedInstance
    }
}
