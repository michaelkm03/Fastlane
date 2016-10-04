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
    var delegate: LoadingCancellableViewDelegate?
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView! {
        didSet {
            activityIndicatorView.startAnimating()
            self.frame.size = CGSize(width: 120, height: 120)
        }
    }
    @IBOutlet weak var text: UILabel! {
        didSet {
            let rendering = NSLocalizedString("Rendering...", comment: "")
            text.text = "  \(rendering)"
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.cornerRadius = 5
            cancelButton.layer.borderColor = UIColor.white.cgColor
            cancelButton.layer.borderWidth = 1
            cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: UIControlState())
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: AnyObject) {
        activityIndicatorView.stopAnimating()
        delegate?.cancel()
    }

}
