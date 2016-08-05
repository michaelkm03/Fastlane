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
    
    optional var searchController: UISearchController { get }
    
    /// If the search UI contains a cancel button, respond to its selection
    func searchResultsViewControllerDidSelectCancel()
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject)
}

class SearchResultsViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, VPaginatedDataSourceDelegate {
    
    private static let defaultSearchResultCellHeight: CGFloat = 50.0
    
    weak var searchResultsDelegate: SearchResultsViewControllerDelegate? {
        didSet {
            onDidSetSearchBarDelegate()
        }
    }
    var dependencyManager: VDependencyManager?
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .White)
        view.color = UIColor.blackColor().colorWithAlphaComponent(0.5)
        view.hidesWhenStopped = true
        return view
    }()
    
    var state: VDataSourceState {
        return self.dataSource?.state ?? .Cleared
    }
    
    var dataSource: SearchDataSourceType? {
        didSet {
            onDidSetDataSource()
        }
    }
    
    @IBOutlet private var tableView: UITableView!
    
    var noContentView: VNoContentView?
    
    // MARK: - Public
    
    func reloadIndexPaths( indexPaths: [NSIndexPath] ) {
        self.tableView.reloadRowsAtIndexPaths( indexPaths, withRowAnimation: .None)
    }
    
    func clear() {
        dataSource?.unload()
    }
    
    func cancel() {
        dataSource?.cancelCurrentOperation()
    }
    
    func search( searchTerm searchTerm: String, completion: ((NSError?) -> ())? = nil ) {
        
        // Clear if we are starting from the beginning
        if let lastSearchTerm = dataSource?.searchTerm
            where !searchTerm.containsString(lastSearchTerm) {
                dataSource?.unload()
        }
        dataSource?.search(searchTerm: searchTerm, pageType: .First, completion: completion)
    }
    
    // MARK: - UIViewController
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource?.delegate = self
        onDidSetSearchBarDelegate()
        
        view.insertSubview(activityIndicatorView, aboveSubview: tableView)
        view.v_addCenterHorizontallyConstraintsToSubview(activityIndicatorView)
        view.v_addPinToTopToSubview(activityIndicatorView, topMargin: activityIndicatorView.bounds.height)
        
        // Removes the separaters for empty rows
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        onDidSetDataSource()
        updateTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    private func onDidSetSearchBarDelegate() {
        searchResultsDelegate?.searchController?.searchBar.delegate = self
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let searchResult = dataSource?.visibleItems[ indexPath.row ] {
            searchResultsDelegate?.searchResultsViewControllerDidSelectResult(searchResult)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SearchResultsViewController.defaultSearchResultCellHeight
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dataSource?.cancelCurrentOperation()
        searchResultsDelegate?.searchResultsViewControllerDidSelectCancel()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            search( searchTerm: searchText )
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.isEmpty {
            clear()
        } else {
            search( searchTerm: searchText )
        }
    }
    
    var searchTerm: String? {
        return dataSource?.searchTerm
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        if oldValue.count > 0 && newValue.count > 0 {
            tableView.flashScrollIndicators()
        }
        
        tableView.v_applyChangeInSection(0, from: oldValue, to: newValue)
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        
        updateTableView()
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
        self.v_showErrorDefaultError()
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
        
        tableView.separatorStyle = dataSource.visibleItems.count > 0 ? .SingleLine : .None
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
            activityIndicatorView.startAnimating()
            
        case .Cleared:
            if searchTerm?.characters.isEmpty ?? false {
                tableView.backgroundView = nil
            }
            activityIndicatorView.stopAnimating()
            
        default:
            tableView.backgroundView = nil
            activityIndicatorView.stopAnimating()
        }
    }
}
