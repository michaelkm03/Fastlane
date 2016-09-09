//
//  LoginOperation.swift
//  victorious
//
//  Created by Tian Lan on 2/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class LoginOperation: AsyncOperation<AccountCreateResponse> {
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager, email: String, password: String) {
        self.dependencyManager = dependencyManager
        requestOperation = RequestOperation(request: LoginRequest(email: email, password: password))
        super.init()
    }
    
    // MARK: - Executing
    
    private let dependencyManager: VDependencyManager
    private let requestOperation: RequestOperation<LoginRequest>
    
    var requestExecutor: RequestExecutorType {
        get {
            return requestOperation.requestExecutor
        }
        set {
            requestOperation.requestExecutor = newValue
        }
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(finish: (result: OperationResult<AccountCreateResponse>) -> Void) {
        let parameters = AccountCreateParameters(loginType: .Email, accountIdentifier: requestOperation.request.email)
        
        requestOperation.queue { [weak self] requestResult in
            guard
                let strongSelf = self,
                let response = requestResult.output
            else {
                finish(result: requestResult)
                return
            }
            
            LoginSuccessOperation(
                dependencyManager: strongSelf.dependencyManager,
                response: response,
                parameters: parameters
            ).queue { loginSuccessResult in
                switch loginSuccessResult {
                    case .success: finish(result: requestResult)
                    case .failure(let error): finish(result: .failure(error))
                    case .cancelled: finish(result: .cancelled)
                }
            }
        }
    }
}
