//
//  VUploadManager.swift
//  victorious
//
//  Created by Tian Lan on 9/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VUploadManager {
    func mockCurrentUser() {
        let user = User(id: 123)
        VCurrentUser.update(to: user)
    }
}
