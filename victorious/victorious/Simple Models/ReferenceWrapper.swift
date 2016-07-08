//
//  ReferenceWrapper.swift
//  victorious
//
//  Created by Jarod Long on 6/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A thin wrapper class around an arbitrary value that allows you to pass value types through reference-oriented APIs.
class ReferenceWrapper<Value>: NSObject {
    let value: Value
    
    init(_ value: Value) {
        self.value = value
    }
}
