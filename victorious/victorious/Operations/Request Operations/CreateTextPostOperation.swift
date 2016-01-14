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
    
    var request: CreateTextPostRequest!

    init?(parameters: TextPostParameters) {
        self.request = CreateTextPostRequest(parameters: parameters)
        super.init()
        if request == nil {
            return nil
        }
    }

    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
