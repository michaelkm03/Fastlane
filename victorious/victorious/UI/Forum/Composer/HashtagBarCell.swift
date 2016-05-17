//
//  HashtagBarCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class HashtagBarCell: VBaseCollectionViewCell {
    
    private var awokeFromNib = false
    
    @IBOutlet weak var label: UILabel!
    
    override var bounds: CGRect {
        didSet {
            updateCornerRadius()
        }
    }
    
    override func awakeFromNib() {
        awokeFromNib = true
        label.clipsToBounds = true
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        label.layer.cornerRadius = bounds.height / 2
    }
}
