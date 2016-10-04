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
    
    func sendRequest(_ url: NSURL, eventIndex: Int, completion: @escaping (NSError?) -> Void) {
        let request = ApplicationTrackingRequest(trackingURL: url as URL, eventIndex: eventIndex)
        DispatchQueue.global().async {
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
