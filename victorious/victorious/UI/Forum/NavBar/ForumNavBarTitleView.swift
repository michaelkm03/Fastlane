//
//  ForumNavBarTitleView.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ForumNavBarTitleView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()
    private let dependencyManager: VDependencyManager
    private let configuration: TitleViewConfiguration
    
    var activeUserCount: Int {
        didSet {
            subtitleLabel.text = getSubtitleText()
        }
    }
    
    init?(dependencyManager: VDependencyManager, frame: CGRect) {
        self.dependencyManager = dependencyManager
        activeUserCount = 0
        
        guard let configuration = dependencyManager.titleViewConfiguration() else {
            // No valid configuration was set. We should not show a titleView
            return nil
        }
        self.configuration = configuration
        
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
        
        titleLabel.text = configuration.titleText
        titleLabel.font = configuration.titleFont
        titleLabel.textColor = configuration.titleColor
        stackView.addArrangedSubview(titleLabel)
        titleLabel.sizeToFit()
        
        subtitleLabel.text = getSubtitleText()
        subtitleLabel.font = configuration.subtitleFont
        subtitleLabel.textColor = configuration.subtitleColor
        stackView.addArrangedSubview(subtitleLabel)
        subtitleLabel.sizeToFit()
        
        addSubview(stackView)
        v_addFitToParentConstraintsToSubview(stackView, leading: 0.0, trailing: 0.0, top: 0.0, bottom: 5.0)
    }
    
    //Creates the string for the subtitle label
    private func getSubtitleText() -> String {
        let numberOfUsersText = activeUserCount == 1 ? configuration.singularNumberOfUsersText : configuration.pluralNumberOfUsersText
        
        return numberOfUsersText
            .stringByReplacingOccurrencesOfString(Keys.visitorsMacro, withString: VLargeNumberFormatter()
            .stringForInteger(activeUserCount))
    }
}

private extension VDependencyManager {
    func titleViewConfiguration() -> TitleViewConfiguration? {
        guard
            let titleColor = colorForKey(Keys.titleColorKey),
            let subtitleColor = colorForKey(Keys.subtitleColorKey),
            let titleFont = fontForKey(Keys.titleFontKey),
            let subtitleFont = fontForKey(Keys.subtitleFontKey),
            let titleText = stringForKey(Keys.titleTextKey),
            let singularNumberOfUsersText = stringForKey(Keys.singularNumberOfUsersTextKey),
            let pluralNumberOfUsersText = stringForKey(Keys.pluralNumberOfUsersTextKey)
        else {
            return nil
        }
        
        return TitleViewConfiguration(
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            titleFont: titleFont,
            subtitleFont: subtitleFont,
            titleText: titleText,
            singularNumberOfUsersText: singularNumberOfUsersText,
            pluralNumberOfUsersText: pluralNumberOfUsersText
        )
    }
}

private struct TitleViewConfiguration {
    let titleColor: UIColor
    let subtitleColor: UIColor
    let titleFont: UIFont
    let subtitleFont: UIFont
    let titleText: String
    let singularNumberOfUsersText: String
    let pluralNumberOfUsersText: String
}

private struct Keys {
    //Dependency Manager Keys
    static let titleColorKey = "color.title.vip"
    static let subtitleColorKey = "color.subtitle.vip"
    static let titleFontKey = "font.title.vip"
    static let subtitleFontKey = "font.subtitle.vip"
    static let titleTextKey = "title.text"
    static let singularNumberOfUsersTextKey = "numberOfUsers.singular.text"
    static let pluralNumberOfUsersTextKey = "numberOfUsers.plural.text"
    static let visitorsMacro = "%%VISITORS%%"
}
