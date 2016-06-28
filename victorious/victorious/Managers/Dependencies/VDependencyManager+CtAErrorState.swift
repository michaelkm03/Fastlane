//
//  VDependencyManager+CtAErrorState.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    /// The calling parent view must provide constraints or a new frame for this view
    func createErrorStateView(withKey key: String = "error.state", actionType: CtAErrorStateActionType) -> CtAErrorState? {
        if let childManager = childDependencyForKey(key) {
            return CtAErrorState(frame: CGRect(), dependencyManager: childManager, actionType: actionType)
        }
        else {
            return nil
        }
    }
}
