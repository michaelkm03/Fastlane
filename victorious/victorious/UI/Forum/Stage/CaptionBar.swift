//
//  CaptionBar.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class CaptionBar: UIView {
    let collapsedNumberOfLines = 2
    let expandedNumberOfLines = 5
    
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var expandButton: TouchableInsetAdjustableButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet var verticalLabelPaddingConstraints: [NSLayoutConstraint]!
    @IBOutlet var avatarButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet var labelWidthConstraint: NSLayoutConstraint!
    @IBOutlet var avatarButtonTopConstraint: NSLayoutConstraint!
}
