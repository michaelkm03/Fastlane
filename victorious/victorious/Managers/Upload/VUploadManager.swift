//
//  VUploadManager.swift
//  victorious
//
//  Created by Tian Lan on 9/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VUploadManager {
    /// Mocks current user for testing purpose.
    
    /// - warning: I converted this to swift from an objective-c legacy code. Do not use outside of testing.
    func mockCurrentUser() {
        let user = User(id: 123)
        VCurrentUser.update(to: user)
    }
}
