//
//  UsernameAvailabilityOperation.swift
//  victorious
//
//  Created by Michael Sena on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class UsernameAvailabilityOperation: AsyncOperation<Bool> {
    init?(apiPath: APIPath, usernameToCheck: String, appID: String){
        guard let request = UsernameAvailabilityRequest(apiPath: apiPath, usernameToCheck: usernameToCheck, appID: appID) else {
            return nil
        }
        self.request = request
        super.init()
    }
    
    private let request:UsernameAvailabilityRequest
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Bool>) -> Void) {
        RequestOperation(request: request).queue { result in
            switch result {
                case .success(_):
                    finish(result: result)
                case .failure(_), .cancelled:
                    finish(result: result)
            }
        }
    }
    
    
}
