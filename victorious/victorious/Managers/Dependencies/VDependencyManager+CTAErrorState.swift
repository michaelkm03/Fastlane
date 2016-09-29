//
//  VDependencyManager+CTAErrorState.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager {
    /// The calling parent view must provide constraints or a new frame for this view
    func createErrorStateView(withKey key: String = "error.state", actionType: CTAErrorStateActionType) -> CTAErrorState? {
        if let childManager = childDependency(forKey: key) {
            return CTAErrorState(frame: CGRectZero, dependencyManager: childManager, actionType: actionType)
        }
        else {
            return nil
        }
    }
}
