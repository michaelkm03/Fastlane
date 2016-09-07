//
//  PasswordRequestResetOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PasswordRequestResetOperation: RemoteFetcherOperation {
    
    let request: RequestPasswordResetRequest!
    private(set) var deviceToken: String = ""
    
    init(email: String) {
        self.request = RequestPasswordResetRequest(email: email)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete( results: RequestPasswordResetRequest.ResultType) {
        deviceToken = results
    }
}
