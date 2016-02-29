//
//  AcknowledgeAlertOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class AcknowledgeAlertOperation: RemoteFetcherOperation, RequestOperation {
    
    let request: AcknowledgeAlertRequest!
    
    init(alertID: Int) {
        self.request = AcknowledgeAlertRequest(alertID: alertID)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
