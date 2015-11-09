//
//  KVOHelper.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/19/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation

class KVOHelper: NSObject {
    typealias Callback = (String?, AnyObject?, [String : AnyObject]?, UnsafeMutablePointer<Void>)->()
    let callback: Callback
    
    init( callback: Callback ) {
        self.callback = callback
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        self.callback( keyPath, object, change, context )
    }
}