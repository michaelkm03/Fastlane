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

class AccountCreateOperation: RemoteFetcherOperation, RequestOperation {
    
    private let dependencyManager: VDependencyManager
    let request: AccountCreateRequest!
    let parameters: AccountCreateParameters
    private(set) var registeredUserID: Int?
    
    init(dependencyManager: VDependencyManager, request: AccountCreateRequest, parameters: AccountCreateParameters) {
        self.dependencyManager = dependencyManager
        self.parameters = parameters
        self.request = request
        super.init()
        
        requiresAuthorization = false
    }
    
    // MARK: - Operation overrides
    
    override func main() {
        requestExecutor.executeRequest( request, onComplete: onComplete, onError: nil )
    }
    
    func onComplete( response: AccountCreateResponse) {
        registeredUserID = response.user.id
        
        LoginSuccessOperation(
            dependencyManager: dependencyManager,
            response: response,
            parameters: self.parameters
        ).rechainAfter(self).queue()
    }
}
