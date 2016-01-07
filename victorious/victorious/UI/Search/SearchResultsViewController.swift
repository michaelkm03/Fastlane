//
//  SearchResultsViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol PaginatedDataSourceType: class {
    var currentOperation: RequestOperation? { get }
    var isLoading: Bool { get }
    var visibleItems: NSOrderedSet { get }
    var delegate: PaginatedDataSourceDelegate? { set get }
    
    func cancelCurrentOperation()
    func unload()
    func loadPage<T: PaginatedOperation>( pageType: VPageType, @noescape createOperation: () -> T, completion: ((operation: T?, error: NSError?) -> Void)? )
}

protocol SearchDataSourceType: class, PaginatedDataSourceType, UITableViewDataSource {
    func search(searchTerm searchTerm: String, pageType: VPageType, completion:((NSError?)->())? )
    var searchTerm: String? { get }
    var error: NSError? { get }
}

protocol SearchResultsViewControllerType {
    func clear()
    func search(searchTerm searchTerm: String)
    
    var searchController: UISearchController { set get }
    var dataSource: SearchDataSourceType { set get }
    var noContentView: VNoContentView? { get set }
    var searchResultsDelegate: SearchResultsViewControllerDelegate? { set get }
}

@objc protocol SearchResultsViewControllerDelegate: class {
    func searchResultsViewControllerDidSelectCancel()
    func searchResultsViewControllerDidSelectResult(result: UserSearchResultObject)
}

class SearchResultsViewController : UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDelegate, VScrollPaginatorDelegate, PaginatedDataSourceDelegate, SearchResultsViewControllerType {
    
    weak var searchResultsDelegate: SearchResultsViewControllerDelegate?
    var dependencyManager: VDependencyManager?
    
    enum SearchState {
        case Loading
        case Cleared
        case NoResults
        case Results
        case Error
    }
    
    private(set) var state: SearchState = .Cleared {
        didSet {
            onSearchStateUpdated();
        }
    }
    
    var searchController: UISearchController = UISearchController() {
        didSet {
            searchController.searchBar.delegate = self
        }
    }
    
    var dataSource: SearchDataSourceType = UserSearchDataSource() {
        didSet {
            dataSource.delegate = self
            tableView.reloadData()
        }
    }
    
    @IBOutlet private var tableView: UITableView!
    
    var noContentView: VNoContentView? {
        didSet {
            setupNoContentView()
        }
    }

    private lazy var scrollPaginator: VScrollPaginator = {
        let paginator = VScrollPaginator()
        paginator.delegate = self
        return paginator
    }()
    
    // MARK: - Public
    
    func clear() {
        dataSource.unload()
        state = .Cleared
    }
    
    func search( searchTerm searchTerm: String ) {
        dataSource.search(searchTerm: searchTerm, pageType: .First) { error in
            self.updateSearchState()
        }
        state = .Loading
    }
    
    // MARK: - UIViewController
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.delegate = self
        dataSource.delegate = self

        tableView.dataSource = dataSource
        tableView.delegate = self
        
        onSearchStateUpdated()
        setupNoContentView()
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
        searchResultsDelegate?.searchResultsViewControllerDidSelectResult(searchResult)
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
        searchBar.resignFirstResponder()
        dataSource.cancelCurrentOperation()
        searchResultsDelegate?.searchResultsViewControllerDidSelectCancel()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchTerm = searchBar.text {
            self.search(searchTerm: searchTerm)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.isEmpty {
            self.clear()
        }
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        if let searchTerm = dataSource.searchTerm where !dataSource.isLoading {
            self.dataSource.search(searchTerm: searchTerm, pageType: .Next, completion: nil)
        }
    }
    
    // MARK: - PaginatedDataSourceDelegate
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        updateSearchState()
        
        if oldValue.count > 0 && newValue.count > 0 {
            tableView.flashScrollIndicators()
        }
    }
    
    // MARK: - Private
    
    private func setupNoContentView() {
        if let noContentView = noContentView where isViewLoaded() && noContentView.superview == nil {
            view.insertSubview(noContentView, belowSubview: tableView)
            view.v_addFitToParentConstraintsToSubview(noContentView)
        }
    }
    
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
            let wasHidden = noContentView?.hidden ?? false
            noContentView?.hidden = false
            tableView.hidden = true
            
            if wasHidden {
                noContentView?.resetInitialAnimationState()
            }
            noContentView?.animateTransitionIn()
            tableView.separatorStyle = .None
            
        case .Error:
            noContentView?.hidden = true
            tableView.hidden = true
            tableView.separatorStyle = .None
            
        case .Cleared, .Loading where dataSource.visibleItems.count == 0:
            noContentView?.hidden = true
            tableView.hidden = false
            tableView.separatorStyle = .None
            
        default:
            noContentView?.hidden = true
            tableView.hidden = false
            tableView.separatorStyle = .SingleLine
        }
        
        tableView.reloadData()
    }
}
