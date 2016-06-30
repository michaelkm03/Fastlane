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
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet var verticalLabelPaddingConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var avatarImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelWidthConstraint: NSLayoutConstraint!
}
