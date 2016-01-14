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
    var state: DataSourceState { get }
    var visibleItems: NSOrderedSet { get }
    var delegate: PaginatedDataSourceDelegate? { set get }
    
    func cancelCurrentOperation()
    func unload()
    func loadPage<T: PaginatedOperation>( pageType: VPageType, @noescape createOperation: () -> T, completion: ((operation: T?, error: NSError?) -> Void)? )
}

protocol SearchDataSourceType: class, PaginatedDataSourceType, UITableViewDataSource {
    func registerCells( forTableView tableView: UITableView )
    func search(searchTerm searchTerm: String, pageType: VPageType, completion:((NSError?)->())? )
    var searchTerm: String? { get }
    var error: NSError? { get }
}

@objc protocol SearchResultsViewControllerDelegate: class {
    func searchResultsViewControllerDidSelectCancel()
    func searchResultsViewControllerDidSelectResult(result: AnyObject)
}

class SearchResultsViewController : UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDelegate, VScrollPaginatorDelegate, PaginatedDataSourceDelegate {
    
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
    
    var dataSource: SearchDataSourceType! {
        didSet {
            onDidSetDataSource()
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
    
    func cancel() {
        dataSource.cancelCurrentOperation()
        updateSearchState()
    }
    
    func search( searchTerm searchTerm: String ) {
        dataSource.search(searchTerm: searchTerm, pageType: .Refresh) { error in
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
        tableView.separatorStyle = .None
        
        onDidSetDataSource()
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
        let searchResult = dataSource.visibleItems[ indexPath.row ]
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
        if let searchTerm = dataSource.searchTerm where dataSource.state != .Loading {
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
    
    private func onDidSetDataSource() {
        guard isViewLoaded() else {
            return
        }
        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        dataSource.registerCells( forTableView: tableView )
    }
    
    private func setupNoContentView() {
        if let noContentView = noContentView where isViewLoaded() && noContentView.superview == nil {
            view.insertSubview(noContentView, belowSubview: tableView)
            view.v_addFitToParentConstraintsToSubview(noContentView)
        }
    }
    
    private func updateSearchState() {
        if dataSource.error != nil {
            state = .Error
            
        } else if state != .Cleared && dataSource.state != .Loading {
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
            
        case .Error:
            noContentView?.hidden = true
            tableView.hidden = true
            
        case .Cleared, .Loading where dataSource.visibleItems.count == 0:
            noContentView?.hidden = true
            tableView.hidden = false
            
        default:
            noContentView?.hidden = true
            tableView.hidden = false
        }
        
        tableView.reloadData()
    }
}
