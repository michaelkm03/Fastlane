//
//  MediaSearchNoContentCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A cell used to show a loading, error or no results state in GIF search
class MediaSearchNoContentCell: UICollectionViewCell {
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    /// Sets text value for a label to indicate to the user the state of the search
    var text = "" {
        didSet {
            label.text = text
        }
    }
    
    /// Puts the cell in or out of a loading state that shows an activity indicator
    var loading = true {
        didSet {
            activityIndicator.isHidden = !loading
        }
    }
}
