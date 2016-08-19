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
