//
//  SearchResultsViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc protocol SearchResultsViewControllerDelegate: class {
    
    /// If the search UI contains a cancel button, respond to its selection
    func searchResultsViewControllerDidSelectCancel()
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject)
}

class SearchResultsViewController : UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDelegate, VScrollPaginatorDelegate, PaginatedDataSourceDelegate {
    
    weak var searchResultsDelegate: SearchResultsViewControllerDelegate?
    var dependencyManager: VDependencyManager?
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        view.color = UIColor.blackColor().colorWithAlphaComponent(0.5)
        view.hidesWhenStopped = true
        return view
    }()
    
    var state: DataSourceState {
        return self.dataSource?.state ?? .Cleared
    }
    
    var searchController: UISearchController = UISearchController() {
        didSet {
            searchController.searchBar.delegate = self
        }
    }
    
    var dataSource: SearchDataSourceType? {
        didSet {
            onDidSetDataSource()
        }
    }
    
    @IBOutlet private var tableView: UITableView!
    
    var noContentView: VNoContentView?

    private lazy var scrollPaginator: VScrollPaginator = {
        let paginator = VScrollPaginator()
        paginator.delegate = self
        return paginator
    }()
    
    // MARK: - Public
    
    func clear() {
        dataSource?.unload()
    }
    
    func cancel() {
        dataSource?.cancelCurrentOperation()
    }
    
    func search( searchTerm searchTerm: String, completion:((NSError?)->())? = nil ) {
        dataSource?.unload()
        dataSource?.search(searchTerm: searchTerm, pageType: .First, completion: completion)
    }
    
    // MARK: - UIViewController
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.delegate = self
        dataSource?.delegate = self
        
        view.insertSubview(activityIndicatorView, aboveSubview: tableView)
        view.v_addCenterHorizontallyConstraintsToSubview(activityIndicatorView)
        view.v_addPinToTopToSubview(activityIndicatorView, topMargin: activityIndicatorView.bounds.height)
        
        // Removes the separaters for empty rows
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        onDidSetDataSource()
        updateTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Unable to immediately make the searchBar first responder without this hack
        dispatch_after(0.01) {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let searchResult = dataSource?.visibleItems[ indexPath.row ] {
            searchResultsDelegate?.searchResultsViewControllerDidSelectResult(searchResult)
        }
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
        dataSource?.cancelCurrentOperation()
        searchResultsDelegate?.searchResultsViewControllerDidSelectCancel()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchTerm = searchBar.text {
            search(searchTerm: searchTerm, completion:nil)
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.isEmpty {
            clear()
        }
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        guard let dataSource = dataSource,
            let searchTerm = dataSource.searchTerm where dataSource.state != .Loading else {
                return
        }
        dataSource.search(searchTerm: searchTerm, pageType: .Next, completion: nil)
    }
    
    // MARK: - PaginatedDataSourceDelegate
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        if oldValue.count > 0 && newValue.count > 0 {
            tableView.flashScrollIndicators()
        }
        
        // FIXME: tableView.v_applyChangeInSection(0, from: oldValue, to: newValue)
        tableView.reloadData()
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: DataSourceState, to newState: DataSourceState) {
        
        updateTableView()
    }

    // MARK: - Private
    
    private func onDidSetDataSource() {
        guard isViewLoaded() else {
            return
        }
        dataSource?.delegate = self
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        dataSource?.registerCells( forTableView: tableView )
    }
    
    func updateTableView() {
        
        guard let dataSource = self.dataSource else {
            tableView.backgroundView = nil
            activityIndicatorView.stopAnimating()
            return
        }
        
        let preferredStyle = dataSource.separatorStyle
        tableView.separatorStyle = dataSource.visibleItems.count > 0 ? preferredStyle : .None
        let isAlreadyShowingNoContent = tableView.backgroundView == noContentView
        
        switch dataSource.state {
            
        case .Error, .NoResults:
            guard let tableView = self.tableView else {
                break
            }
            if !isAlreadyShowingNoContent {
                noContentView?.resetInitialAnimationState()
                noContentView?.animateTransitionIn()
            }
            
            noContentView?.frame = tableView.bounds
            tableView.backgroundView = noContentView
            activityIndicatorView.stopAnimating()
            
        case .Loading where dataSource.visibleItems.count == 0:
            tableView.backgroundView = nil
            activityIndicatorView.startAnimating()
            
        default:
            tableView.backgroundView = nil
            activityIndicatorView.stopAnimating()
        }
    }
}
