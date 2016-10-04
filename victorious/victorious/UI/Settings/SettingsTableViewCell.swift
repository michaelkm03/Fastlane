//
//  SettingsTableViewCell.swift
//  victorious
//
//  Created by Jarod Long on 7/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell, VBackgroundContainer {

    fileprivate let separatorView: UIView

    var separatorColor: UIColor {
        get {
            return separatorView.backgroundColor ?? UIColor.clear
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

        separatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    // MARK: - Views
    
    @IBOutlet fileprivate var label: UILabel!
    
    // MARK: - Values
    
    var settingName: String {
        return label.text ?? ""
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return backgroundView ?? contentView
    }
}
