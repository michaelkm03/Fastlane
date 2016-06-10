//
//  ForumNavBarTitleView.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ForumNavBarTitleView: UIView {
    
    private var titleLabel: UILabel
    private var subtitleLabel: UILabel
    private var stackView: UIStackView
    private let dependencyManager: VDependencyManager
    
    var numActiveUsers: Int {
        didSet {
            subtitleLabel.text = getSubtitleText()
        }
    }
    
    init(dependencyManager: VDependencyManager, frame: CGRect) {
        self.dependencyManager = dependencyManager
        numActiveUsers = 0
        
        //Initialize these to stub view for now
        stackView = UIStackView()
        titleLabel = UILabel()
        subtitleLabel = UILabel()
        
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        //Initialize the stack view and set the layout information
        stackView.axis = .Vertical
        stackView.distribution = .FillProportionally
        stackView.alignment = .Center
        
        titleLabel.text = dependencyManager.stringForKey(Keys.titleTextKey)
        titleLabel.font = dependencyManager.fontForKey(Keys.titleFontKey)
        titleLabel.textColor = dependencyManager.colorForKey(Keys.titleColorKey)
        stackView.addArrangedSubview(titleLabel)
        titleLabel.sizeToFit()
        
        subtitleLabel.text = getSubtitleText()
        subtitleLabel.font = dependencyManager.fontForKey(Keys.subtitleFontKey)
        subtitleLabel.textColor = dependencyManager.colorForKey(Keys.subtitleColorKey)
        stackView.addArrangedSubview(subtitleLabel)
        subtitleLabel.sizeToFit()
        
        self.addSubview(stackView)
        self.v_addFitToParentConstraintsToSubview(stackView)
    }
    
    //Creates the string for the subtitle label
    private func getSubtitleText() -> String {
        return "\(numActiveUsers) " + (dependencyManager.numActiveUsersStringByReplacingMacro() ?? "users")
    }
    
}

private extension VDependencyManager {
    func numActiveUsersStringByReplacingMacro () -> String? {
        guard let displayString = self.templateValueOfType(NSString.self, forKey: Keys.numberOfUsersTextKey, withAddedDependencies: [:]) as? String else {
            return nil
        }
        return displayString.stringByReplacingOccurrencesOfString(Keys.visitorsMacro, withString: "")
    }
}

private struct Keys {
    //Dependency Manager Keys
    static let titleColorKey = "color.title.vip"
    static let subtitleColorKey = "color.subtitle.vip"
    static let titleFontKey = "font.title.vip"
    static let subtitleFontKey = "font.subtitle.vip"
    static let titleTextKey = "title.text"
    static let numberOfUsersTextKey = "numberOfUsers.text"
    static let visitorsMacro = "%%VISITORS%%"
}
