//
//  LoginOperation.swift
//  victorious
//
//  Created by Tian Lan on 2/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class LoginOperation: RequestOperation {
    
    let request: LoginRequest
    
    init(email: String, password: String) {
        request = LoginRequest(email: email, password: password)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }
    
    func onComplete(response: AccountCreateResponse, completion: () -> ()) {
        let parameters = AccountCreateParameters(loginType: .Email, accountIdentifier: self.request.email)
        let successOperation = LoginSuccessOperation(response: response, parameters: parameters)
        successOperation.rechainAndQueueAfter(self, queue: defaultQueue)
        completion()
    }
}
