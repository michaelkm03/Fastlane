//
//  GridStreamViewController.swift
//  victorious
//
//  Created by Vincent Ho on 4/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

struct GridStreamConfiguration {
    var sectionInset = UIEdgeInsetsMake(0, 0, 3, 0)
    var interItemSpacing = CGFloat(3)
    var cellsPerRow = 3
    var allowsForRefresh = true
}

class GridStreamViewController<HeaderType: ConfigurableGridStreamHeader>: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, ContentCellTracker {
    
    // MARK: Variables
    
    let dependencyManager: VDependencyManager
    fileprivate let collectionView = UICollectionView(
        frame: CGRect.zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    fileprivate let dataSource: GridStreamDataSource<HeaderType>

    fileprivate(set) var content: HeaderType.ContentType?
    fileprivate var hasError: Bool = false
    
    func setContent(_ content: HeaderType.ContentType?, withError hasError: Bool) {
        self.content = content
        self.hasError = hasError
        updateTrackingParameters()
        dataSource.setContent(content, withError: hasError)
        
        header?.decorateHeader(
            dependencyManager,
            withWidth: 0,
            maxHeight: (collectionView.bounds).height,
            content: content,
            hasError: hasError
        )
        collectionView.reloadSections(IndexSet(integer: GridStreamSection.header.rawValue))

    }
    
    fileprivate let refreshControl = UIRefreshControl()
    
    fileprivate var scrollPaginator = ScrollPaginator()
    fileprivate let configuration: GridStreamConfiguration
    
    fileprivate var header: HeaderType?
    
    fileprivate var trackingParameters: [AnyHashable: Any] = [:]
    
    // MARK: - ContentCellTracker
    
    var sessionParameters: [AnyHashable: Any] {
        return trackingParameters
    }
    
    // MARK: - Initializing
    
    init(
        dependencyManager: VDependencyManager,
        header: HeaderType? = nil,
        content: HeaderType.ContentType?,
        configuration: GridStreamConfiguration? = nil,
        streamAPIPath: APIPath
    ) {
        self.dependencyManager = dependencyManager
        self.header = header
        self.content = content
        self.configuration = configuration ?? GridStreamConfiguration()
        
        dataSource = GridStreamDataSource<HeaderType>(
            dependencyManager: dependencyManager,
            header: header,
            content: content,
            streamAPIPath: streamAPIPath
        )
        
        super.init(nibName: nil, bundle: nil)
        
        updateTrackingParameters()
        
        dataSource.registerViewsFor(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = UIColor.clear
        collectionView.alwaysBounceVertical = true
        
        edgesForExtendedLayout = .Bottom
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(collectionView)
        view.v_addFitToParentConstraintsToSubview(collectionView)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = self.configuration.interItemSpacing
            flowLayout.sectionInset = self.configuration.sectionInset
            flowLayout.minimumLineSpacing = self.configuration.interItemSpacing
        }
        
        if self.configuration.allowsForRefresh {
            refreshControl.tintColor = dependencyManager.refreshControlColor
            refreshControl.addTarget(
                self,
                action: #selector(refresh),
                forControlEvents: .ValueChanged
            )
            collectionView.insertSubview(refreshControl, atIndex: 0)
        }
        
        scrollPaginator.tolerance += CollectionLoadingView.preferredHeight
        
        scrollPaginator.loadItemsBelow = { [weak self] in
            self?.loadContent(.older)
        }
        
        loadContent(.refresh)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - Refreshing
    
    func reloadHeader() {
        collectionView.reloadSections(IndexSet(integer: GridStreamSection.header.rawValue))
    }
    
    func refresh() {
        loadContent(.refresh)
        header?.gridStreamShouldRefresh()
    }
    
    fileprivate func loadContent(_ loadingType: PaginatedLoadingType) {
        guard !dataSource.isLoading else {
            return
        }
        
        dataSource.loadContent(for: collectionView, loadingType: loadingType) { [weak self] result in
            // Calling this method stops scrolling, so only do it if necessary.
            if self?.refreshControl.refreshing == true {
                self?.refreshControl.endRefreshing()
            }
            
            switch result {
                case .success(_): break
                case .failure(_): (self?.navigationController ?? self)?.v_showErrorDefaultError()
            }
            
            self?.collectionView.collectionViewLayout.invalidateLayout()
        }
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Configuration
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollPaginator.scrollViewDidScroll(scrollView)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard
            section == GridStreamSection.header.rawValue,
            let header = header
        else {
            return CGSize.zero
        }
        
        let size = header.sizeForHeader(
            dependencyManager,
            withWidth: collectionView.frame.width,
            maxHeight: collectionView.frame.height,
            content: content,
            hasError: hasError
        )
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        return flowLayout.v_cellSize(
            fittingWidth: collectionView.bounds.width,
            cellsPerRow: configuration.cellsPerRow
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if let loadingView = view as? CollectionLoadingView {
            loadingView.color = dependencyManager.refreshControlColor
            loadingView.isLoading = dataSource.isLoading
        }
        else if elementKind == UICollectionElementKindSectionHeader {
            header?.headerDidAppear()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if elementKind == UICollectionElementKindSectionHeader {
            header?.headerWillDisappear()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard section == GridStreamSection.contents.rawValue else {
            return CGSize.zero
        }
        
        return dataSource.hasLoadedAllItems ? CGSize.zero : CollectionLoadingView.preferredSize(in: collectionView.bounds)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let targetContent = dataSource.items[indexPath.row]
        
        let destination = DeeplinkDestination(content: targetContent)
        let context: DeeplinkContext?
        if type(of: header?) == CloseUpView.self {
            context = DeeplinkContext(value: DeeplinkContext.closeupView)
        }
        else if type(of: header?) == VNewProfileHeaderView.self {
            context = DeeplinkContext(value: DeeplinkContext.userProfile)
        }
        else {
            context = nil
        }
        router.navigate(to: destination, from: context)
        header?.headerWillDisappear()

        guard let content = (collectionView.cellForItem(at: indexPath) as? ContentCell)?.content else {
            return
        }

        trackView(.cellClick, showingContent: content, parameters: [:])
    }

    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let content = (cell as? ContentCell)?.content else {
            return
        }

        trackView(.cellView, showingContent: content, parameters: [:])
    }
    
    // MARK: - Tracking updating
    
    fileprivate func updateTrackingParameters() {
        if
            let content = content as? Content,
            let contentId = content.id
        {
            trackingParameters = [ VTrackingKeyParentContentId : contentId ]
        }
    }
}

private extension VDependencyManager {
    var refreshControlColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
}
