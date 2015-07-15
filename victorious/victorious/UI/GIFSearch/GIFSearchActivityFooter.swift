//
//  GIFSearchActivityFooter.swift
//  victorious
//
//  Created by Patrick Lynch on 7/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Collection view footer that shows acitivyt indicator or a message, intended
/// for letting the user know when there are no more results to load.
class GIFSearchActivityFooter: UICollectionReusableView {
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var loading: Bool = true {
        didSet {
            self.activityIndicator.hidden = false
        }
    }
    
    var title: String = "" {
        didSet {
            self.label.text = self.title
            self.loading = self.title == ""
        }
    }
}