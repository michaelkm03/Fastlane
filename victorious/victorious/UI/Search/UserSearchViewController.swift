//
//  UserSearchViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class UserSearchViewController: UINavigationController, SearchResultsViewControllerDelegate {
    
    weak var searchResultsDelegate: SearchResultsViewControllerDelegate?
    
    private var dependencyManager: VDependencyManager!
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> UserSearchViewController {
        let viewController: UserSearchViewController = UserSearchViewController.v_initialViewControllerFromStoryboard()
        viewController.dependencyManager = dependencyManager
        if let listViewController = viewController.viewControllers.first as? SearchResultsViewController {
            listViewController.dependencyManager = dependencyManager
        }
        return viewController
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let viewController = viewControllers.first,
            var searchResultsViewControler = viewController as? SearchResultsViewControllerType {
                
                searchResultsViewControler.searchResultsDelegate = self
                
                let searchController = UISearchController(searchResultsController: nil)
                searchController.searchBar.sizeToFit()
                searchController.hidesNavigationBarDuringPresentation = false
                searchController.dimsBackgroundDuringPresentation = false
                searchResultsViewControler.searchController = searchController
                dependencyManager.configureSearchBar(searchController.searchBar)
                
                if #available(iOS 9.1, *) {
                    searchController.obscuresBackgroundDuringPresentation = false
                }
                viewController.definesPresentationContext = true // So the presentation doesn't cover our view
                viewController.navigationItem.titleView = searchController.searchBar
                
                let noContentView: VNoContentView = VNoContentView.v_fromNib()
                noContentView.translatesAutoresizingMaskIntoConstraints = false
                noContentView.icon = UIImage(named: "user-icon")
                noContentView.title = NSLocalizedString("NoUserSearchResultsTitle", comment:"")
                noContentView.message = NSLocalizedString("NoUserSearchResultsMessage", comment:"")
                noContentView.resetInitialAnimationState()
                noContentView.setDependencyManager( self.dependencyManager! )
                searchResultsViewControler.noContentView = noContentView
        }
        
        dependencyManager.applyStyleToNavigationBar(navigationBar)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: - SearchResultsViewControllerDelegate
    
    func searchResultsViewControllerDidSelectCancel() {
        searchResultsDelegate?.searchResultsViewControllerDidSelectCancel()
    }
    
    func searchResultsViewControllerDidSelectResult(result: UserSearchResultObject) {
        searchResultsDelegate?.searchResultsViewControllerDidSelectResult( result )
    }
}

private extension VDependencyManager {
    
    var userHashtagSearchKey: String { return "userHashtagSearch" }
    var searchIconImageName: String { return "D_search_small_icon" }
    var searchClearImageName: String { return "search_clear_icon" }
    
    func configureSearchBar(searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = true
        searchBar.tintColor = self.colorForKey(VDependencyManagerSecondaryTextColorKey)
        searchBar.v_textField?.tintColor = self.colorForKey(VDependencyManagerLinkColorKey)
        searchBar.v_textField?.font = self.fontForKey(VDependencyManagerLabel3FontKey)
        searchBar.v_textField?.textColor = self.colorForKey(VDependencyManagerSecondaryTextColorKey)
        searchBar.v_textField?.backgroundColor = self.colorForKey(VDependencyManagerSecondaryAccentColorKey)
        searchBar.v_textField?.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Start a new conversation", comment: ""),
            attributes: [NSForegroundColorAttributeName: self.colorForKey(VDependencyManagerPlaceholderTextColorKey)]
        )
        
        // Made 2 UIImage instances with the same image asset because we cannot
        // set the same instance for .Highlight and .Normal
        guard var searchIconImage = UIImage(named: searchIconImageName),
            var searchClearImageHighlighted = UIImage(named: searchClearImageName),
            var searchClearImageNormal = UIImage(named: searchClearImageName) else {
                return
        }
        
        searchIconImage = searchIconImage.v_tintedTemplateImageWithColor(self.colorForKey(VDependencyManagerPlaceholderTextColorKey))
        searchBar.setImage(searchIconImage, forSearchBarIcon: .Search, state: .Normal)
        
        searchClearImageHighlighted = searchClearImageHighlighted.v_tintedTemplateImageWithColor(self.colorForKey(VDependencyManagerPlaceholderTextColorKey).colorWithAlphaComponent(0.5))
        searchBar.setImage(searchClearImageHighlighted, forSearchBarIcon: .Clear, state: .Highlighted)
        
        searchClearImageNormal = searchClearImageNormal.v_tintedTemplateImageWithColor(self.colorForKey(VDependencyManagerPlaceholderTextColorKey))
        searchBar.setImage(searchClearImageNormal, forSearchBarIcon: .Clear, state: .Normal)
    }
}
