//
//  PastableTextView.swift
//  victorious
//
//  Created by Sebastian Nystorm on 14/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol PastableTextViewDelegate: class {
    var canShowPasteMenu: Bool { get }
    var canShowCopyMenu: Bool { get }
    var canShowCutMenu: Bool { get }
    var canShowSelectMenu: Bool { get }

    /// imageObject is required for sizing information, imageData is required for gif
    func didPasteImage(image: (imageObject: UIImage, imageData: NSData))
    func didPasteText(text: String)
}

/// Subclass of VPlaceholderTextView to allow pasting of media content into the composer.
class PastableTextView: VPlaceholderTextView {

    var pastableDelegate: PastableTextViewDelegate?

    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        guard let pastableDelegate = pastableDelegate else {
            return super.canPerformAction(action, withSender: sender)
        }

        var canPerformAction = false

        switch action {
            case #selector(copy(_:) ):
                canPerformAction = pastableDelegate.canShowCopyMenu
            case #selector(cut(_: ) ):
                canPerformAction = pastableDelegate.canShowCutMenu
            case #selector(select(_: ) ):
                canPerformAction = pastableDelegate.canShowSelectMenu
            case #selector(paste(_:) ):
                canPerformAction = pastableDelegate.canShowPasteMenu
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
        } else if let text = pasteboard.string {
            pastableDelegate.didPasteText(text)
        }
    }
}
