//
//  LoginOperation.swift
//  victorious
//
//  Created by Tian Lan on 2/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class LoginOperation: RemoteFetcherOperation, RequestOperation {
    
    private let dependencyManager: VDependencyManager
    let request: LoginRequest!
    
    init(dependencyManager: VDependencyManager, email: String, password: String) {
        self.dependencyManager = dependencyManager
        request = LoginRequest(email: email, password: password)
        super.init()
        
        requiresAuthorization = false
    }
    
    override func main() {
        guard !cancelled else {
            return
        }
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete(response: AccountCreateResponse) {
        let parameters = AccountCreateParameters(loginType: .Email, accountIdentifier: self.request.email)
        LoginSuccessOperation(
            dependencyManager: dependencyManager,
            response: response,
            parameters: parameters
        ).rechainAfter(self).queue()
    }
}
