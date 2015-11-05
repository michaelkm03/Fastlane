//
//  VCancelable.swift
//  victorious
//
//  Created by Josh Hinman on 11/4/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// An objective-c compatible wrapper for the Cancelable protocol
class VCancelable: NSObject, Cancelable {
    private let innerCancelable: Cancelable
    
    init(_ cancelable: Cancelable) {
        innerCancelable = cancelable
    }
    
    func cancel() {
        innerCancelable.cancel()
    }
}
