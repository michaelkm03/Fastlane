//
//  OperationResult.swift
//  victorious
//
//  Created by Jarod Long on 9/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// This enum represents the result of executing an operation.
enum OperationResult<Output> {
    /// When the operation successfully finishes executing, and produces results of `Output` type. `Output` can be Void if no results is expected from the operation.
    case success(Output)
    
    /// When the operation failed with a specific error. Use this case when there's an error that should be surfaced to the user.
    case failure(ErrorType)
    
    /// When the operation was cancelled either by the caller, or determined to not be able to execute without a user facing error.
    case cancelled
    
    /// The output that the operation produced, or nil if the result did not succeed.
    var output: Output? {
        switch self {
            case .success(let output): return output
            case .failure(_), .cancelled: return nil
        }
    }
    
    /// The error that the operation produced, or nil if the result did not fail.
    var error: ErrorType? {
        switch self {
            case .failure(let error): return error
            case .success(_), .cancelled: return nil
        }
    }
}
