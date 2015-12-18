//
//  AcknowledgeAlertOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class AcknowledgeAlertOperation: RequestOperation {
    
    let request: AcknowledgeAlertRequest
    
    init(alertID: Int64) {
        self.request = AcknowledgeAlertRequest(alertID: alertID)
    }
    
    override func main() {
        self.executeRequest( self.request )
    }
}
