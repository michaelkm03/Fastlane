//
//  SettingsEmptyCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class SettingsEmptyCell: UITableViewCell {
    
    @IBOutlet private weak var label: UILabel!
    
    var message: String = "" {
        didSet {
            self.label.text = message
        }
    }
    
    func clear() {
        self.message = ""
    }
}
