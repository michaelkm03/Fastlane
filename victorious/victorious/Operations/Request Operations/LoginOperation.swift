//
//  LoginOperation.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class LoginOperation: RequestOperation {
    let request: LoginRequest

    init(email: String, password: String) {
        request = LoginRequest(email: email, password: password)
        super.init()
    }

    override func main() {
        requestExecutor.executeRequest(request, onComplete: onComplete, onError: nil)
    }

    func onComplete(user: LoginRequest.ResultType, completion: ()->()) {
    }
}
