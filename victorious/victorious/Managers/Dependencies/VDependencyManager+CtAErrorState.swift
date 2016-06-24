//
//  VDependencyManager+CtAErrorState.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    func createErrorStateView(withKey key: String = "error.state", actionType: CtAErrorStateActionType) -> UIView {
        if let childManager = childDependencyForKey(key) {
            return CtAErrorState(frame: CGRect(), dependencyManager: childManager, actionType: actionType)
        }
        else {
            return UIView()
        }
    }
}