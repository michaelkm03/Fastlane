//
//  AlertAcknowledgeOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class AlertAcknowledgeOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: AcknowledgeAlertRequest!
    
    init(alertID: Double) {
        self.request = AcknowledgeAlertRequest(alertID: alertID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
