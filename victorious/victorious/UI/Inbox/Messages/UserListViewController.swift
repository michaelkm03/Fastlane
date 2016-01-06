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

class UserListViewController : UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDelegate, VScrollPaginatorDelegate, UserSearchDataSourceDelegate {
    
    private enum UserSearchState {
        case Default
        case LoadingInitial
        case LoadingSubsequent
        case NoResults
        case FoundUsers
    }
    
    private struct Constants {
        static let userHashtagSearchKey = "userHashtagSearch"
        static let searchIconImageName = "D_search_small_icon"
        static let searchClearImageName = "search_clear_icon"
    }
    
    weak var delegate : UserListViewControllerDelegate?
    var dependencyManager: VDependencyManager?
    
    private let userSearchDataSource = UserSearchDataSource()
    private let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var noResultsView: UIView!
    @IBOutlet private var noResultsTitleLabel: UILabel!
    @IBOutlet private var noResultsMessageLabel: UILabel!

    private lazy var scrollPaginator: VScrollPaginator = {
        let paginator = VScrollPaginator()
        paginator.delegate = self
        return paginator
    }()
    
    private var searchState = UserSearchState.Default {
        didSet {
            switch searchState {
            case .Default:
                noResultsView.hidden = true
                tableView.hidden = false
            case .LoadingInitial:
                noResultsView.hidden = true
                tableView.hidden = false
            case .LoadingSubsequent:
                noResultsView.hidden = true
                tableView.hidden = false
            case .NoResults:
                noResultsView.hidden = false
                tableView.hidden = true
            case .FoundUsers:
                noResultsView.hidden = true
                tableView.hidden = false
            }
        }
    }
    
    //MARK: - UIViewController
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userSearchDataSource.delegate = self
        
        // NO RESULTS VIEW
        noResultsTitleLabel.font = dependencyManager?.fontForKey(VDependencyManagerHeading1FontKey)
        noResultsMessageLabel.font = dependencyManager?.fontForKey(VDependencyManagerHeading4FontKey)
        
        configureSearchController(searchController)
        configureSearchBar(searchController.searchBar)
        
        navigationItem.titleView = searchController.searchBar

        self.tableView.dataSource = userSearchDataSource
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCurrentSearchState()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Unable to immediately make the searchBar first responder without this hack
        dispatch_after(0.01) { () -> () in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let user = userSearchDataSource.userForIndexPath(indexPath) else {
            return
        }
        delegate?.userListViewControllerDidSelectUserID(self, user: user)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        userSearchDataSource.bindCell(cell, forIndexPath: indexPath)
    }
    
    //MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
        delegate?.userListViewControllerDidSelectCancel()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // Peform Search
        if let searchBarText = searchBar.text {
            userSearchDataSource.searchWithNewSearchQuery(searchBarText)
        }
    }
    
    //MARK: - UISearchControllerDelegate
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    //MARK: - UserSearchDataSourceDelegate
    
    func dataSourceDidUpdate(dataSource: UserSearchDataSource) {
        updateCurrentSearchState()
        tableView.reloadData()
        tableView.flashScrollIndicators()
    }
    
    //MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        // Bail early if we are loading already
        guard !userSearchDataSource.isLoading else {
            return
        }
        
        userSearchDataSource.loadNextPage({ [weak self] error in
            guard let strongSelf = self else {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                strongSelf.updateCurrentSearchState()
            })
        })
        // So we see the loading next page indicator
        self.tableView.reloadData()
        updateCurrentSearchState()
    }

    //MARK: - Private Methods
    
    func updateCurrentSearchState() {
        guard userSearchDataSource.searchQuery != nil else {
            self.searchState = .Default
            return
        }
        
        if userSearchDataSource.isLoading {
            if userSearchDataSource.visibleItems.count == 0 {
                self.searchState = .LoadingInitial
            } else {
                self.searchState = .LoadingSubsequent
            }
        } else {
            if userSearchDataSource.visibleItems.count == 0 {
                self.searchState = .NoResults
            } else {
                self.searchState = .FoundUsers
            }
        }
    }
    
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
