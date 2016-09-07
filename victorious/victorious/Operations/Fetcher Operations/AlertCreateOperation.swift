//
//  AlertCreateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 12/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class AlertCreateOperation: RemoteFetcherOperation {
    
    let request: CreateAlertRequest!
    
    init(type: String, addtionalParameters: [String: AnyObject]? = nil) {
        self.request = CreateAlertRequest(type: type, addtionalParameters:addtionalParameters)
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
