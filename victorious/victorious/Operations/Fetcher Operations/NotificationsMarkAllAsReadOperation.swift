//
//  NotificationsMarkAllAsReadOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class NotificationsMarkAllAsReadOperation: RemoteFetcherOperation {
    
    let request: MarkAllNotificationsAsReadRequest! = MarkAllNotificationsAsReadRequest()
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
