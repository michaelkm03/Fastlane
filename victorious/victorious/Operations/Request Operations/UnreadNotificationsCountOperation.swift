//
//  UnreadNotificationsCountOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class UnreadNotificationsCountOperation: FetcherOperation, RequestOperation {
    
    let request: UnreadNotificationsCountRequest! = UnreadNotificationsCountRequest()
    
    var unreadNotificationsCount: NSNumber?
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( result: UnreadNotificationsCountRequest.ResultType, completion:()->() ) {
        self.unreadNotificationsCount = result
        completion()
    }
}
