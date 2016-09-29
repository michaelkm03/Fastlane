//
//  LoginOperation.swift
//  victorious
//
//  Created by Tian Lan on 2/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//
import VictoriousIOSSDK

class LoginOperation: AsyncOperation<AccountCreateResponse> {
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager, email: String, password: String) {
        self.dependencyManager = dependencyManager
        requestOperation = RequestOperation(request: LoginRequest(email: email, password: password))
        super.init()
    }
    
    // MARK: - Executing
    
    fileprivate let dependencyManager: VDependencyManager
    fileprivate let requestOperation: RequestOperation<LoginRequest>
    
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
    
    override func execute(_ finish: @escaping (_ result: OperationResult<AccountCreateResponse>) -> Void) {
        let parameters = AccountCreateParameters(loginType: .email, accountIdentifier: requestOperation.request.email)
        
        requestOperation.queue { [weak self] requestResult in
            guard
                let strongSelf = self,
                let response = requestResult.output
            else {
                finish(requestResult)
                return
            }
            
            LoginSuccessOperation(
                dependencyManager: strongSelf.dependencyManager,
                response: response,
                parameters: parameters
            ).queue { loginSuccessResult in
                switch loginSuccessResult {
                    case .success: finish(requestResult)
                    case .failure(let error): finish(.failure(error))
                    case .cancelled: finish(.cancelled)
                }
            }
        }
    }
}
