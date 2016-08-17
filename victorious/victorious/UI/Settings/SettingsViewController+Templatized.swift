//
//  SettingsViewController+Templatized.swift
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
    static let supportEmailKey = "email.support"
    static let sectionHeaderTitles = ["Account", "About"]
    static let headerLabelLeftPadding = CGFloat(10.0)
}

/// This extension handles all template based decoration for the settings page, as well as
/// other template based functionality.
extension VSettingsViewController: VBackgroundContainer {
    override public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < Constants.sectionHeaderTitles.count else {
            return nil
        }
        let headerLabel = UILabel()
        headerLabel.text = Constants.sectionHeaderTitles[section]
        headerLabel.font = dependencyManager.headerLabelFont
        headerLabel.textColor = dependencyManager.headerLabelColor
        headerLabel.sizeToFit()
        
        let containerView = UIView()
        containerView.addSubview(headerLabel)
        containerView.v_addFitToParentConstraintsToSubview(headerLabel, leading: Constants.headerLabelLeftPadding, trailing: 0.0, top: 0.0, bottom: 0.0)
        return containerView
    }
    
    override public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let label = cell.textLabel, cell = cell as? SettingsTableViewCell else {
            return
        }
        
        label.font = dependencyManager.cellFont
        label.textColor = dependencyManager.cellTextColor
        label.backgroundColor = UIColor.clearColor()

        cell.separatorColor = isLastCell(indexPath) || isLastSection(indexPath.section) ? UIColor.clearColor() : dependencyManager.separatorColor ?? UIColor.clearColor()

        if cell.contentView.subviews.contains(versionString) {
            cell.backgroundColor = UIColor.clearColor()
        }
        else {
            cell.backgroundView = UIView() // Must set this here so that we can add a background
            dependencyManager.addBackgroundToBackgroundHost(cell, forKey: Constants.itemBackgroundKey)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityIdentifier = VAutomationIdentifierSettingsTableView
        tableView.backgroundView = UIView()
        dependencyManager.addBackgroundToBackgroundHost(self)
        tableView.separatorStyle = .None
    }
    
    public func backgroundContainerView() -> UIView {
        return tableView.backgroundView ?? self.view
    }
    
    public func handleAboutSectionSelection(row: Int) {
        switch row {
            case 0: showFixedWebContent(.HelpCenter)
            case 1: sendHelp()
            case 2: showFixedWebContent(.TermsOfService)
            case 3: showFixedWebContent(.PrivacyPolicy)
            default: break
        }
    }
    
    private func showFixedWebContent(type: FixedWebContentType) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let configuration = ExternalLinkDisplayConfiguration(addressBarVisible: false, forceModal: false, isVIPOnly: false, title: type.title)
        router.navigate(to: .externalURL(url: dependencyManager.urlForWebContent(type), configuration: configuration))
    }
}

private extension VSettingsViewController {
    private func isLastCell(indexPath: NSIndexPath) -> Bool {
        return indexPath.row == tableView.numberOfRowsInSection(indexPath.section) - 1
    }

    private func isLastSection(section: Int) -> Bool {
        return section == tableView.numberOfSections - 1
    }
}

private extension VDependencyManager {
    var headerLabelFont: UIFont? {
        return fontForKey(Constants.sectionTitleFontKey)
    }
    
    var headerLabelColor: UIColor? {
        return colorForKey(Constants.sectionTitleFontColor)
    }
    
    var cellFont: UIFont? {
        return fontForKey(Constants.cellFontKey)
    }
    
    var cellTextColor: UIColor? {
        return colorForKey(Constants.cellColorKey)
    }
    
    var separatorColor: UIColor? {
        return colorForKey(Constants.separatorColorKey)
    }
}
