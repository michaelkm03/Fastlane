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
    
    //Dependency Manager Keys 
    private let titleColorKey = "color.title.vip"
    private let subtitleColorKey = "color.subtitle.vip"
    private let titleFontKey = "font.title.vip"
    private let subtitleFontKey = "font.subtitle.vip"
    private let titleTextKey = "title.text"
    private let numberOfUsersTextKey = "numberOfUsers.text"
    
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
    
    func setupViews() {
        
        //Initialize the stack view and set the layout information
        stackView.axis = .Vertical
        stackView.distribution = .FillProportionally
        stackView.alignment = .Center
        
        titleLabel.text = "Live Chat" //dependencyManager.stringForKey(titleTextKey)
        titleLabel.font = UIFont.systemFontOfSize(12) //dependencyManager.fontForKey(titleFontKey)
        titleLabel.textColor = UIColor.whiteColor() //dependencyManager.colorForKey(titleColorKey)
        stackView.addSubview(titleLabel)
        
        subtitleLabel.text = getSubtitleText()
        subtitleLabel.font = UIFont.systemFontOfSize(8) //dependencyManager.fontForKey(subtitleFontKey)
        subtitleLabel.textColor = UIColor.whiteColor() //dependencyManager.colorForKey(subtitleColorKey) 
        stackView.addSubview(subtitleLabel)
        
        self.addSubview(stackView)
        self.v_addFitToParentConstraintsToSubview(stackView)
        
    }
    
    //Creates the string for the subtitle label
    
    func getSubtitleText() -> String {
        return "\(numActiveUsers) " + " visitors "  //+ dependencyManager.stringForKey(numberOfUsersTextKey)
    }
    
    
    
}
