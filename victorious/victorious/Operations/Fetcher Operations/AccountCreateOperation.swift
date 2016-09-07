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

class AccountCreateOperation: RequestOperation<AccountCreateRequest> {
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager, credentials: NewAccountCredentials, parameters: AccountCreateParameters) {
        self.dependencyManager = dependencyManager
        self.parameters = parameters
        super.init(request: AccountCreateRequest(credentials: credentials))
    }
    
    // MARK: - Executing
    
    private let dependencyManager: VDependencyManager
    private let parameters: AccountCreateParameters
    
    override func execute(finish: (result: OperationResult<AccountCreateRequest.ResultType>) -> Void) {
        super.execute { [weak self] result in
            if
                let strongSelf = self,
                case let .success(response) = result
            {
                LoginSuccessOperation(
                    dependencyManager: strongSelf.dependencyManager,
                    response: response,
                    parameters: strongSelf.parameters
                ).rechainAfter(strongSelf).queue()
            }
            
            finish(result: result)
        }
    }
}
