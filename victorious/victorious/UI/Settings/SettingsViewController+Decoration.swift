//
//  SettingsViewController+Decoration.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private struct Constants {
    static let cellFontKey = "item.font"
    static let cellColorKey = "item.color"
    static let sectionTitleFontKey = "sectionTitle.font"
    static let sectionTitleFontColor = "sectionTitle.color"
    static let versionFontKey = "version.font"
    static let versionColorKey = "version.color"
    static let separatorColorKey = "separator.color"
    static let itemBackgroundKey = "item.background"
    static let screenBackgroundKey = "background"
    static let bundleShortVersionStringKey = "CFBundleShortVersionString"
    static let sectionHeaderTitles = ["Account", "About"]
}

///This extension handles all template based decoration for the settings page
extension VSettingsViewController : VBackgroundContainer {
    override public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < Constants.sectionHeaderTitles.count else {
            return nil
        }
        let headerLabel = UILabel()
        headerLabel.text = Constants.sectionHeaderTitles[section]
        headerLabel.font = dependencyManager.fontForKey(Constants.sectionTitleFontKey)
        headerLabel.textColor = dependencyManager.colorForKey(Constants.sectionTitleFontColor)
        headerLabel.sizeToFit()
        return headerLabel
    }
    
    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let label = cell.textLabel else {
            return
        }
        
        label.font = dependencyManager.fontForKey(Constants.cellFontKey)
        label.textColor = dependencyManager.colorForKey(Constants.cellColorKey)
        label.backgroundColor = UIColor.clearColor()
        cell.backgroundColor = dependencyManager.colorForKey(Constants.itemBackgroundKey)
        //self.dependencyManager.addBackgroundToBackgroundHost(cell, forKey: Constants.itemBackgroundKey)
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.accessibilityIdentifier = VAutomationIdentifierSettingsTableView
        self.tableView.backgroundView = UIView()
        self.dependencyManager.addBackgroundToBackgroundHost(self)
        tableView.separatorColor = dependencyManager.colorForKey(Constants.separatorColorKey)
    }
    
    public func backgroundContainerView() -> UIView {
        return self.tableView.backgroundView ?? self.view
    }
}
