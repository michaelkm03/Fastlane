//
//  VNewProfileViewController.swift
//  victorious
//
//  Created by Jarod Long on 3/31/16.
//  Copyright (c) 2016 Victorious. All rights reserved.
//

import UIKit

/// A view controller that displays the contents of a user's profile.
class VNewProfileViewController: UIViewController, UICollectionViewDelegateFlowLayout, VPaginatedDataSourceDelegate, VScrollPaginatorDelegate, VBackgroundContainer {
    // MARK: - Constants
    
    private static let cellsPerRow = 3
    private static let cellSpacing: CGFloat = 10.0
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        dataSource = VNewProfileStreamDataSource(dependencyManager: dependencyManager)
        
        super.init(nibName: nil, bundle: nil)
        
        dataSource.delegate = self
        dataSource.registerViewsFor(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = nil
        collectionView.alwaysBounceVertical = true
        
        collectionView.registerNib(VFooterActivityIndicatorView.nibForSupplementaryView(),
            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
            withReuseIdentifier: VFooterActivityIndicatorView.reuseIdentifier()
        )
        
        scrollPaginator.delegate = self
        
        edgesForExtendedLayout = .Bottom
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        dependencyManager.addBackgroundToBackgroundHost(self)
        
        view.addSubview(collectionView)
        view.v_addFitToParentConstraintsToSubview(collectionView)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let spacing = VNewProfileViewController.cellSpacing
            flowLayout.minimumInteritemSpacing = spacing
            flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: spacing, bottom: spacing, right: spacing)
        }
        
        refreshControl.tintColor = dependencyManager.refreshControlColor
        refreshControl.addTarget(self, action: #selector(VNewProfileViewController.refresh), forControlEvents: .ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        setUser()
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Dependency manager
    
    private let dependencyManager: VDependencyManager
    
    // MARK: - Views
    
    private let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Data source
    
    private let dataSource: VNewProfileStreamDataSource
    
    // MARK: - Pagination
    
    private let scrollPaginator = VScrollPaginator()
    
    // MARK: - User
    
    private var user: VUser? {
        didSet {
            if user !== oldValue {
                dataSource.user = user
                dataSource.loadStreamItems(.First)
                collectionView.reloadData()
            }
        }
    }
    
    private func setUser() {
        if let user = dependencyManager.templateValueOfType(VUser.self, forKey: VDependencyManagerUserKey) as? VUser {
            self.user = user
        }
        else if let userRemoteID = dependencyManager.templateValueOfType(NSNumber.self, forKey: VDependencyManagerUserRemoteIdKey) as? NSNumber {
            let userInfoOperation = UserInfoOperation(userID: userRemoteID.integerValue)
            
            userInfoOperation.queue { [weak self] results, error, cancelled in
                self?.user = userInfoOperation.user
            }
        }
        else {
            user = VCurrentUser.user()
        }
    }
    
    // MARK: - Refreshing
    
    func refresh() {
        dataSource.loadStreamItems(.First) { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Configuration
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    /// A second copy of the header view that allows us to calculate the header's height based on its constraints.
    private let sizingHeaderView: VNewProfileHeaderView = UIView.v_fromNib("VNewProfileHeaderView")
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        sizingHeaderView.dependencyManager = dependencyManager
        sizingHeaderView.user = user
        sizingHeaderView.setNeedsLayout()
        sizingHeaderView.layoutIfNeeded()
        
        let width = view.bounds.width
        let widthConstraint = sizingHeaderView.v_addWidthConstraint(width)
        let height = sizingHeaderView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        
        sizingHeaderView.removeConstraint(widthConstraint)
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return dataSource.isLoading() ? VFooterActivityIndicatorView.desiredSizeWithCollectionViewBounds(collectionView.bounds) : CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        return flowLayout.v_cellSize(
            fittingWidth: collectionView.bounds.width,
            cellsPerRow: VNewProfileViewController.cellsPerRow
        )
    }
    
    func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        if let footerView = view as? VFooterActivityIndicatorView {
            footerView.activityIndicator.color = dependencyManager.refreshControlColor
            footerView.setActivityIndicatorVisible(dataSource.isLoading(), animated: true)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        collectionView.v_applyChangeInSection(0, from: oldValue, to: newValue, animated: false)
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        if oldState == .Loading {
            refreshControl.endRefreshing()
        }
        
        if newState == .Loading || oldState == .Loading {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
        (navigationController ?? self).v_showErrorDefaultError()
    }
    
    // MARK: - VScrollPaginatorDelegate
    
    func shouldLoadNextPage() {
        dataSource.loadStreamItems(.Next)
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
}

private extension VDependencyManager {
    var refreshControlColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
}
