//
//  SettingsButtonCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

protocol SettingsButtonCellDelegate {
    func buttonPressed( button: UIButton )
}

class SettingsButtonCell: UITableViewCell {
    
    var delegate: SettingsButtonCellDelegate?
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonPressed( sender: UIButton ) {
        self.delegate?.buttonPressed( sender )
    }
    
}