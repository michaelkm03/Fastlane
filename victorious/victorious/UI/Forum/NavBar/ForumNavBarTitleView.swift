//
//  ForumNavBarTitleView.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ForumNavBarTitleView: UIView {
    fileprivate let titleLabel = UILabel()
    fileprivate let subtitleLabel = UILabel()
    fileprivate let stackView = UIStackView()
    fileprivate let dependencyManager: VDependencyManager
    fileprivate let configuration: TitleViewConfiguration
    
    var activeUserCount: Int {
        didSet {
            subtitleLabel.text = getSubtitleText()
        }
    }
    
    init?(dependencyManager: VDependencyManager, frame: CGRect) {
        self.dependencyManager = dependencyManager
        activeUserCount = 1
        
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
    
    fileprivate func setupViews() {
        //Initialize the stack view and set the layout information
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        
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
        v_addFitToParentConstraints(toSubview: stackView, leading: 0.0, trailing: 0.0, top: 0.0, bottom: 5.0)
    }
    
    //Creates the string for the subtitle label
    fileprivate func getSubtitleText() -> String {
        let numberOfUsersText = activeUserCount == 1 ? configuration.singularNumberOfUsersText : configuration.pluralNumberOfUsersText
        
        return numberOfUsersText
            .replacingOccurrences(of: Keys.visitorsMacro, with: VLargeNumberFormatter()
            .string(for: activeUserCount))
    }
}

private extension VDependencyManager {
    func titleViewConfiguration() -> TitleViewConfiguration? {
        guard
            let titleColor = color(forKey: Keys.titleColorKey),
            let subtitleColor = color(forKey: Keys.subtitleColorKey),
            let titleFont = font(forKey: Keys.titleFontKey),
            let subtitleFont = font(forKey: Keys.subtitleFontKey),
            let titleText = string(forKey: Keys.titleTextKey),
            let singularNumberOfUsersText = string(forKey: Keys.singularNumberOfUsersTextKey),
            let pluralNumberOfUsersText = string(forKey: Keys.pluralNumberOfUsersTextKey)
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
