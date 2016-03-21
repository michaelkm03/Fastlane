//
//  ActionConfirmationOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ActionConfirmationOperation {
    var didConfirmAction: Bool { get }
}

extension NSOperation {
    
    /// Checks the `dependencies` array for operations conforming to `ActionConfirmationOperation`
    /// and returns true if *all* operations return true for `didConfirmAction`.  This makes
    /// multiple confirmations possible.  If there were no `ActionConfirmationOperation` operations,
    /// this value will return true and operations may assume that no confirmation was needed.
    var didConfirmActionFromDependencies: Bool {
        
        // Make sure *any* previous confirmation operations did confirm this action
        return !cancelled && dependencies.flatMap { $0 as? ActionConfirmationOperation }.reduce( true ) {
            return $0 && $1.didConfirmAction
        }
    }
}