//
//  CreatePollOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class CreatePollOperation: RequestOperation {
    
    let request: PollCreateRequest
    
    private init(request: PollCreateRequest) {
        self.request = request
    }
    
    convenience init?( parameters: PollParameters ) {
        if let request = PollCreateRequest(parameters: parameters) {
            self.init(request: request)
        } else {
            return nil
        }
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
