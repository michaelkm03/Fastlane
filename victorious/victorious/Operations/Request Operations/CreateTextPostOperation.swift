//
//  CreateTextPostOperation.swift
//  victorious
//
//  Created by Tian Lan on 1/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class CreateTextPostOperation: RequestOperation {
    
    /// `request` is implicitly unwrapped to solve the failable initializer EXC_BAD_ACCESS bug when returning nil
    /// Reference: Swift Documentation, Section "Failable Initialization for Classes":
    /// https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Initialization.html
    var request: CreateTextPostRequest!

    init?(parameters: TextPostParameters) {
        self.request = CreateTextPostRequest(parameters: parameters)
        super.init()
        if request == nil {
            return nil
        }
    }

    override func main() {
        requestExecutor.executeRequest( request, onComplete: nil, onError: nil )
    }
}
