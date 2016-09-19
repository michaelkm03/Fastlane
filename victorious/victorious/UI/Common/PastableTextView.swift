//
//  PastableTextView.swift
//  victorious
//
//  Created by Sebastian Nystorm on 14/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol PastableTextViewDelegate: class {
    func canShowPasteMenu() -> Bool

    func canShowCopyMenu() -> Bool

    func didPasteImage(image: (imageObject: UIImage, imageData: NSData))
}

class PastableTextView: VPlaceholderTextView {

    var pastableDelegate: PastableTextViewDelegate?

    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        guard let pastableDelegate = pastableDelegate else {
            return super.canPerformAction(action, withSender: sender)
        }

        var canPerformAction = false

        switch action {
            case #selector(copy(_:) ):
                canPerformAction = pastableDelegate.canShowCopyMenu()
            case #selector(paste(_:) ):
                canPerformAction = pastableDelegate.canShowPasteMenu()
            default:
                super.canPerformAction(action, withSender: sender)
        }
        return canPerformAction
    }

    override func paste(sender: AnyObject?) {
        guard let pastableDelegate = pastableDelegate else {
            return
        }

        let pasteboard = UIPasteboard.generalPasteboard()

        if let image = pasteboard.image, let imageData = pasteboard.dataForPasteboardType("public.image") {
            pastableDelegate.didPasteImage((image, imageData))
        }
    }
}
