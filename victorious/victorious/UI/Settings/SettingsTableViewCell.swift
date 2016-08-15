//
//  SettingsTableViewCell.swift
//  victorious
//
//  Created by Jarod Long on 7/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell, VBackgroundContainer {

    private let separatorView: UIView

    var separatorColor: UIColor {
        get {
            return separatorView.backgroundColor ?? UIColor.clearColor()
        }

        set {
            separatorView.backgroundColor = newValue
        }
    }

    // MARK: - Initializing

    required init?(coder aDecoder: NSCoder) {
        separatorView = UIView()

        super.init(coder: aDecoder)

        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)

        separatorView.leadingAnchor.constraintEqualToAnchor(leadingAnchor).active = true
        separatorView.trailingAnchor.constraintEqualToAnchor(trailingAnchor).active = true
        separatorView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        separatorView.heightAnchor.constraintEqualToConstant(1).active = true
    }

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
