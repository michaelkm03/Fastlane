//
//  UITextView+ConvenienceInit.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension UITextView {
    class func unselectableInstance() -> Self {
        let textView = self.init()
        textView.selectable = false
        return textView
    }
}
