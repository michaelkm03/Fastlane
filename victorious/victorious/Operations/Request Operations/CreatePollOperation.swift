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
    
    var request: PollCreateRequest
    
    private let parameters: PollParameters
    
    private init(request: PollCreateRequest, parameters: PollParameters) {
        self.request = request
        self.parameters = parameters
    }
    
    convenience init?( parameters: PollParameters ) {
        if let request = PollCreateRequest(parameters: parameters) {
            self.init(request: request, parameters: parameters)
        } else {
            return nil
        }
    }
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
