//
//  VApplicationTracking.swift
//  victorious
//
//  Created by Patrick Lynch on 12/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VApplicationTracking {
    
    func sendRequest(url: NSURL, eventIndex: Int, completion: NSError? -> Void) {
        let request = ApplicationTrackingRequest(trackingURL: url, eventIndex: eventIndex)
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            MainRequestExecutor().executeRequest(request,
                onComplete: { _ in
                    completion(nil)
                },
                onError: { error in
                    completion(error)
                }
            )
        }
    }
}
