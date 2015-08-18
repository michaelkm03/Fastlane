//
//  UIResponder+typedResponder.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

extension UIResponder {
    func targetForAction<T, U: RawRepresentable where U.RawValue == Selector>( action: U, withSender sender: AnyObject?) -> T {
        let r: AnyObject? = self.targetForAction( action.rawValue, withSender: sender )
        if let responder = r as? T {
            return responder
        }
        fatalError( "Unable to find responder for selector \"\(action.rawValue)\" in chain." )
    }
    
    func typedResponder<T>() -> T {
        var responder: UIResponder? = self.nextResponder()
        do {
            if let typedResponder = responder as? T {
                return typedResponder
            }
            responder = responder?.nextResponder()
        }
        while responder != nil
        fatalError( "Unable to find typed responder." )
    }
}
