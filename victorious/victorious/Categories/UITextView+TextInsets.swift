//
//  UITextView+TextInsets.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/30/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension UITextView {
    var v_textInsets: UIEdgeInsets {
        return UIEdgeInsetsMake(contentInset.top + textContainerInset.top,
                                contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding,
                                contentInset.bottom + textContainerInset.bottom,
                                contentInset.right + textContainerInset.right + textContainer.lineFragmentPadding)
    }
}
