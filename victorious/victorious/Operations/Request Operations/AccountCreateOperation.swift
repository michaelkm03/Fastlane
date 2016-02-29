//
//  AccountCreateOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

struct AccountCreateParameters {
    let loginType: VLoginType
    let accountIdentifier: String?
}

class AccountCreateOperation: FetcherOperation, RequestOperation {
    
    let request: AccountCreateRequest!
    let parameters: AccountCreateParameters
    
    init( request: AccountCreateRequest, parameters: AccountCreateParameters) {
        self.parameters = parameters
        self.request = request
        super.init()
        
        requiresAuthorization = false
    }
    
    // MARK: - Operation overrides
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( response: AccountCreateResponse, completion:()->() ) {
        let successOperation = LoginSuccessOperation(response: response, parameters: self.parameters)
        successOperation.rechainAfter(self).queue()
        completion()
    }
}
