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
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    var text: String = "" {
        didSet {
            self.label.text = text
            if text != "" {
                self.activityIndicator.hidden = true
            }
        }
    }
    
    func clear() {
        self.text = ""
    }
    
    var loading: Bool = true {
        didSet {
            self.clear()
            self.activityIndicator.hidden = false
        }
    }
}