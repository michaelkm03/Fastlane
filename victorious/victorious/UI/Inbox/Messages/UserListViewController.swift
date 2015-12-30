//
//  UserListTableViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol UserListViewControllerDelegate: NSObjectProtocol {
    
    // Your delegate implementation should dismiss the UserListViewController
    func userListViewControllerDidSelectCancel()
    
    // Your delegate implementation should dismiss the UserListViewController
    func userListViewControllerDidSelectUserID(listViewController: UserListViewController, user: User)
}

class UserListViewController : UIViewController, UISearchBarDelegate, UISearchControllerDelegate {
    
    private struct Constants {
        static let userHashtagSearchKey = "userHashtagSearch"
        static let searchIconImageName = "D_search_small_icon"
        static let searchClearImageName = "search_clear_icon"
    }
    
    weak var delegate : UserListViewControllerDelegate?
    var dependencyManager: VDependencyManager?
    
    private var userSearchDataManagerTableViewAdapter: UserSearchDataManagerTableViewAdapter?
    private let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var noResultsView: UIView!
    @IBOutlet private var noResultsTitleLabel: UILabel!
    @IBOutlet private var noResultsMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NO RESULTS VIEW
        noResultsTitleLabel.font = dependencyManager?.fontForKey(VDependencyManagerHeading1FontKey)
        noResultsMessageLabel.font = dependencyManager?.fontForKey(VDependencyManagerHeading4FontKey)
        
        configureSearchController(searchController)
        configureSearchBar(searchController.searchBar)
        
        navigationItem.titleView = searchController.searchBar
        
        userSearchDataManagerTableViewAdapter = UserSearchDataManagerTableViewAdapter(tableView: self.tableView,
            dependencyManager: self.dependencyManager!,
            noResultsView: self.noResultsView, userSelectionHandler: { [weak self]user in
                if let strongSelf = self {
                    strongSelf.delegate?.userListViewControllerDidSelectUserID(strongSelf, user: user)
                }
        })
        self.tableView.dataSource = userSearchDataManagerTableViewAdapter
        self.tableView.delegate = userSearchDataManagerTableViewAdapter
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        userSearchDataManagerTableViewAdapter?.updateCurrentSearchState()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Unable to immediately make the searchBar first responder without this hack
        dispatch_after(0.01) { () -> () in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    //MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
        delegate?.userListViewControllerDidSelectCancel()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // Peform Search
        if let searchBarText = searchBar.text {
            userSearchDataManagerTableViewAdapter?.searchQuery = searchBarText
        }
    }
    
    //MARK: - UISearchControllerDelegate
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }

    //MARK: - Private Methods
    
    func configureSearchController(searchController: UISearchController) {
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true // So the presentation doesn't cover our view
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
    }
    
    func configureSearchBar(searchBar: UISearchBar) {
        guard let dependencyManager = dependencyManager else {
            return
        }
        
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        searchBar.tintColor = dependencyManager.colorForKey(VDependencyManagerSecondaryTextColorKey)
        searchBar.v_textField?.tintColor = dependencyManager.colorForKey(VDependencyManagerLinkColorKey)
        searchBar.v_textField?.font = dependencyManager.fontForKey(VDependencyManagerLabel3FontKey)
        searchBar.v_textField?.textColor = dependencyManager.colorForKey(VDependencyManagerSecondaryTextColorKey)
        searchBar.v_textField?.backgroundColor = dependencyManager.colorForKey(VDependencyManagerSecondaryAccentColorKey)
        searchBar.v_textField?.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("Start a new conversation", comment: ""),
            attributes: [NSForegroundColorAttributeName: dependencyManager.colorForKey(VDependencyManagerPlaceholderTextColorKey)]
        )
        
        // Made 2 UIImage instances with the same image asset because we cannot
        // set the same instance for .Highlight and .Normal
        guard var searchIconImage = UIImage(named: Constants.searchIconImageName),
            var searchClearImageHighlighted = UIImage(named: Constants.searchClearImageName),
            var searchClearImageNormal = UIImage(named: Constants.searchClearImageName) else {
                return
        }
        
        searchIconImage = searchIconImage.v_tintedTemplateImageWithColor(dependencyManager.colorForKey(VDependencyManagerPlaceholderTextColorKey))
        searchBar.setImage(searchIconImage, forSearchBarIcon: .Search, state: .Normal)
        
        searchClearImageHighlighted = searchClearImageHighlighted.v_tintedTemplateImageWithColor(dependencyManager.colorForKey(VDependencyManagerPlaceholderTextColorKey).colorWithAlphaComponent(0.5))
        searchBar.setImage(searchClearImageHighlighted, forSearchBarIcon: .Clear, state: .Highlighted)
        
        searchClearImageNormal = searchClearImageNormal.v_tintedTemplateImageWithColor(dependencyManager.colorForKey(VDependencyManagerPlaceholderTextColorKey))
        searchBar.setImage(searchClearImageNormal, forSearchBarIcon: .Clear, state: .Normal)
    }
}
