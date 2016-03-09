//
//  LoadingCancellableView.swift
//  victorious
//
//  Created by Vincent Ho on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol LoadingCancellableViewDelegate {
    func cancel()
}

class LoadingCancellableView: UIView {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    var delegate: LoadingCancellableViewDelegate!
    
    override func awakeFromNib() {
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderColor = UIColor.whiteColor().CGColor
        cancelButton.layer.borderWidth = 1
        activityIndicatorView.startAnimating()
        let rendering = NSLocalizedString("Rendering", comment: "")
        text.text = "  \(rendering)..."
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), forState: .Normal)
        self.frame.size = CGSizeMake(120, 120)
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        activityIndicatorView.stopAnimating()
        self.delegate?.cancel()
    }

}
