//
//  MediaSearchActivityFooter.swift
//  victorious
//
//  Created by Patrick Lynch on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Collection view footer that shows activity indicator or a message, intended
/// for letting the user know when there are no more results to load.
class MediaSearchActivityFooter: UICollectionReusableView {
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    /// Determines whether or not a loading state is represented using an activity indicator view
    var loading: Bool = true {
        didSet {
            self.activityIndicator.isHidden = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // This fixes layout artificats visible when insertions/deletions are being animated
        self.isHidden = self.bounds.width == 0.0
    }
    
    /// The text of a label to display message to the user
    var title: String = "" {
        didSet {
            self.label.text = self.title
            self.loading = self.title == ""
        }
    }
}
