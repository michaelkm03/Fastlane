//
//  MarkAllNotificationsReadOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class MarkAllNotificationsAsReadOperation: FetcherOperation, RequestOperation {
    
    let request: MarkAllNotificationsAsReadRequest! = MarkAllNotificationsAsReadRequest()
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
