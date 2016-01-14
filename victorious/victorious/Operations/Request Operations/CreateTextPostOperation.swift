//
//  CreateTextPostOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class CreateTextPostOperation: RequestOperation {
    
    var request: CreateTextPostRequest
    
    private init(request: CreateTextPostRequest) {
        self.request = request
    }
    
    convenience init?( parameters: TextPostParameters ) {
        if let request = CreateTextPostRequest(parameters: parameters) {
            self.init(request: request)
        } else {
            return nil
        }
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
