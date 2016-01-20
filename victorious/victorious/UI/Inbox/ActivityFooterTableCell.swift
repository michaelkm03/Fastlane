//
//  ActivityFooterCell.swift
//  victorious
//
//  Created by Patrick Lynch on 1/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ActivityFooterTableCell: UITableViewCell {
    
    static func suggestedReuseIdentifier() -> String {
        return StringFromClass(self)
    }
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    /// Determines whether or not a loading state is represented using an activity indicator view
    var loading: Bool = true {
        didSet {
            self.activityIndicator.startAnimating()
            UIView.animateWithDuration(0.3,
                delay: 0.2,
                options: [],
                animations: { () -> Void in
                    self.activityIndicator.alpha = self.loading ? 1.0 : 0.0
                },
                completion: nil
            )
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // This fixes layout artificats visible when insertions/deletions are being animated
        self.hidden = self.bounds.width == 0.0
    }
    
    /// The text of a label to display message to the user
    var title: String = "" {
        didSet {
            self.label.text = self.title
            self.loading = self.title == ""
        }
    }
}
