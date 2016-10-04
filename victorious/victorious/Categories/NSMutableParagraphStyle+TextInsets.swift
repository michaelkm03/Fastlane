//
//  NSMutableParagraphStyle+TextInsets.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSMutableParagraphStyle {
    func v_setTextInsets(_ insets: UIEdgeInsets) {
        firstLineHeadIndent = insets.left
        headIndent = insets.left
        tailIndent = -insets.right
        paragraphSpacingBefore = insets.top
        paragraphSpacing = insets.bottom
    }
}
