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

class AccountCreateOperation: AsyncOperation<AccountCreateResponse> {
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager, credentials: NewAccountCredentials, parameters: AccountCreateParameters) {
        self.dependencyManager = dependencyManager
        self.credentials = credentials
        self.parameters = parameters
        super.init()
    }
    
    // MARK: - Executing
    
    private let dependencyManager: VDependencyManager
    private let credentials: NewAccountCredentials
    private let parameters: AccountCreateParameters
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(finish: (result: OperationResult<AccountCreateResponse>) -> Void) {
        let requestOperation = RequestOperation(request: AccountCreateRequest(credentials: credentials))
        
        requestOperation.queue { [weak self] requestResult in
            guard let strongSelf = self else {
                finish(result: requestResult)
                return
            }
            
            switch requestResult {
                case .success(let response):
                    LoginSuccessOperation(
                        dependencyManager: strongSelf.dependencyManager,
                        response: response,
                        parameters: strongSelf.parameters
                    ).queue { loginSuccessResult in
                        switch loginSuccessResult {
                            case .success: finish(result: requestResult)
                            case .failure(let error): finish(result: .failure(error))
                            case .cancelled: finish(result: .cancelled)
                        }
                    }
                
                case .failure(_), .cancelled:
                    finish(result: requestResult)
            }
        }
    }
}
