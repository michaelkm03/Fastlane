//
//  Callback.swift
//  victorious
//
//  Created by Jarod Long on 8/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A struct that simplifies adding callback functionality to an API.
///
/// To use it, you provide a callback property that users can listen to with `add`, and you use the `call` method to
/// trigger it.
///
public struct Callback<Parameter> {
    public typealias CallbackBlock = (Parameter) -> Void
    
    // MARK: - Initializing
    
    public init() {}
    
    // MARK: - Managing callbacks
    
    private var blocks = [CallbackBlock]()
    
    /// Adds the given block to the callback.
    public mutating func add(_ block: @escaping CallbackBlock) {
        blocks.append(block)
    }
    
    // MARK: - Calling callbacks
    
    /// Calls all of the blocks in the callback.
    public func call(_ parameter: Parameter) {
        for block in blocks {
            block(parameter)
        }
    }
}
