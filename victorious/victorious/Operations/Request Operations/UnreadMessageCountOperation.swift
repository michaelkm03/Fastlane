//
//  UnreadMessageCountOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class UnreadMessageCountOperation: RequestOperation {
    
    private let request = UnreadMessageCountRequest()
    
    var unreadMessagesCount: NSNumber?
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( result: UnreadMessageCountRequest.ResultType, completion:()->() ) {
        self.unreadMessagesCount = result
        completion()
    }
}