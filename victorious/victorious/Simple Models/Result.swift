//
//  Result.swift
//  victorious
//
//  Created by Vincent Ho on 9/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// This enum represents the result of a method call.
enum Result<Output> {
    /// When the call successfully finishes, and produces results of `Output` type. `Output` can be Void if no results are expected.
    case success(Output)
    /// When the call failed with a specific error. Use this case when there's an error that should be surfaced to the user.
    case failure(ErrorType?)
}
