//
//  GIFSearchNoContentCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A cell used to show a loading, error or no results state in GIF search
class GIFSearchNoContentCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "GIFSearchNoContentCell"
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    /// Sets text value for a label to indicate to the user the state of the search
    var text: String = "" {
        didSet {
            self.label.text = text
            if text != "" {
                self.activityIndicator.hidden = true
            }
        }
    }
    
    /// Removes any displaying text
    func clear() {
        self.text = ""
    }
    
    /// Puts the cell in or out of a loading state that shows an activity indicator
    var loading: Bool = true {
        didSet {
            self.clear()
            self.activityIndicator.hidden = false
        }
    }
}