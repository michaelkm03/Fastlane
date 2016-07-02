//
//  SettingsTableViewCell.swift
//  victorious
//
//  Created by Jarod Long on 7/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell, VBackgroundContainer {
    // MARK: - Views
    
    @IBOutlet private var label: UILabel!
    
    // MARK: - Values
    
    var settingName: String {
        return label.text ?? ""
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return backgroundView ?? contentView
    }
}
