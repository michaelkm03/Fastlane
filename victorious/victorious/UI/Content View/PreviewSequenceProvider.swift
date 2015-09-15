//
//  PreviewSequenceProvider.swift
//  victorious
//
//  Created by Patrick Lynch on 9/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// Defines an object that (1) can provide a view from its hiearchy to be handed off to another
/// context (such as the custom transition to `VNewContentViewController`),  and (2) can receive that
/// view when transitioning back from that context and insert it back into its original view hiearchy
@objc protocol VContentPreviewViewProvider {
    func getPreviewView() -> UIView
    func restorePreviewView( previewView: UIView )
}