//
//  UserConfirmationOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that captures the result of a user's confirmation, such as by
/// an alert that asks "Are you sure?" and has a confirmation action like "OK"
protocol UserConfirmationOperation {
    
    var didConfirmAction: Bool { get }
}


extension NSOperation {
    
    /// Checks the `dependencies` array for operations conforming to `UserConfirmationOperation`
    /// and returns true if *all* operations return true for `didConfirmAction`.  This makes
    /// multiple confirmations possible.  If there were no `UserConfirmationOperation` operations,
    /// this value will return true and operations may assume that no confirmation was needed.
    var didConfirmActionFromDependencies: Bool {
        // Make sure *any* previous confirmation operations did confirm this action
        return dependencies.flatMap { $0 as? UserConfirmationOperation }.reduce( true ) {
            $0 || $1.didConfirmAction
        }
    }
}
