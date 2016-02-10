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

    func onComplete(response: LoginResponse, completion: () -> ()) {
        
        storedBackgroundContext = persistentStore.createBackgroundContext().v_performBlock() { context in
            
            // First, find or create the new user who just logged in
            let user: VUser = context.v_findOrCreateObject( [ "remoteId" : response.user.userID ])
            user.populate(fromSourceModel: response.user)
            user.loginType = VLoginType.Email.rawValue
            user.token = response.token
            
            // Save, merging the changes into the main context
            context.v_save()
            
            // After saving, the objectID is available
            let userObjectID = user.objectID
            
            self.persistentStore.mainContext.v_performBlock() { context in
                
                // Reload from main context to continue login process
                guard let user = context.objectWithID(userObjectID) as? VUser else {
                    assertionFailure( "Cannot retrieve user by objectID." )
                    return
                }
                user.setAsCurrentUser()
                self.updateStoredCredentials( user )
                PreloadUserInfoOperation().queueAfter(self)
                completion()
            }
        }
    }
    
    private func updateStoredCredentials( user: VUser ) {
        VStoredLogin().saveLoggedInUserToDisk( user )
        NSUserDefaults.standardUserDefaults().setInteger( user.loginType.integerValue, forKey: kLastLoginTypeUserDefaultsKey )
        NSUserDefaults.standardUserDefaults().setObject( request.email, forKey: kAccountIdentifierDefaultsKey )
    }
}
