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

class UserListViewController : UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDelegate, VScrollPaginatorDelegate, PaginatedDataSourceDelegate {
    
    weak var delegate : UserListViewControllerDelegate?
    var dependencyManager: VDependencyManager?
    
    enum SearchState {
        case Loading
        case Cleared
        case NoResults
        case Results
        case Error
    }
    
    private var state: SearchState = .Cleared {
        didSet {
            onSearchStateUpdated();
        }
    }
    
    private let dataSource = UserSearchDataSource()
    private let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var noContentView: VNoContentView = {
        let view: VNoContentView = VNoContentView.v_fromNib()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.icon = UIImage(named: "user-icon")
        view.title = NSLocalizedString("NoUserSearchResultsTitle", comment:"")
        view.message = NSLocalizedString("NoUserSearchResultsMessage", comment:"")
        view.resetInitialAnimationState()
        view.setDependencyManager( self.dependencyManager! )
        return view
    }()

    private lazy var scrollPaginator: VScrollPaginator = {
        let paginator = VScrollPaginator()
        paginator.delegate = self
        return paginator
    }()
    
    // MARK: - UIViewController
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.delegate = self
        
        searchController.searchBar.sizeToFit()
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true // So the presentation doesn't cover our view
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        
        dependencyManager?.configureSearchBar(searchController.searchBar)
        searchController.searchBar.delegate = self
        
        view.insertSubview(noContentView, belowSubview: tableView)
        view.v_addFitToParentConstraintsToSubview(noContentView)
        
        navigationItem.titleView = searchController.searchBar

        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Unable to immediately make the searchBar first responder without this hack
        dispatch_after(0.01) { () -> () in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let searchResult = dataSource.visibleItems[ indexPath.row ] as? UserSearchResultObject else {
            return
        }
        delegate?.userListViewControllerDidSelectUserID(self, user: searchResult.sourceResult)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
    
    // MARK: - UISearchControllerDelegate
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
        dataSource.cancelCurrentOperation()
        delegate?.userListViewControllerDidSelectCancel()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchTerm = searchBar.text {
            dataSource.search(searchTerm: searchTerm, pageType: .First) { error in
                self.updateSearchState()
            }
            state = .Loading
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.isEmpty {
            dataSource.unload()
            state = .Cleared
        }
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        guard !dataSource.isLoading,
            let searchTerm = dataSource.searchTerm else {
                return
        }
        dataSource.search(searchTerm: searchTerm, pageType: .Next)
        state = .Loading
    }
    
    // MARK: - PaginatedDataSourceDelegate
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        updateSearchState()
        
        if oldValue.count > 0 && newValue.count > 0 {
            tableView.flashScrollIndicators()
        }
    }
    
    // MARK: - Private
    
    private func updateSearchState() {
        if dataSource.error != nil {
            state = .Error
            
        } else if state != .Cleared && !dataSource.isLoading {
            state = dataSource.visibleItems.count == 0 ? .NoResults : .Results
        }
    }
    
    private func onSearchStateUpdated() {
        switch self.state {
        case .NoResults:
            let wasHidden = noContentView.hidden
            noContentView.hidden = false
            tableView.hidden = true
            
            if wasHidden {
                noContentView.resetInitialAnimationState()
            }
            noContentView.animateTransitionIn()
            
        case .Error:
            noContentView.hidden = true
            tableView.hidden = true
            
        default:
            noContentView.hidden = true
            tableView.hidden = false
        }
        
        self.tableView.reloadData()
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
