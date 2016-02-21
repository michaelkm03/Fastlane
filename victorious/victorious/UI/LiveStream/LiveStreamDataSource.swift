//
//  LiveStreamDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

@objc protocol VExtendedCollectionViewDataSource: NSObjectProtocol {
    
    func decorateCell( cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
    
    func registerCells( collectionView: UICollectionView )
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
}

class LiveStreamDataSource: NSObject, UICollectionViewDataSource, VPaginatedDataSourceDelegate, VExtendedCollectionViewDataSource {
    
    let sizingCell: LiveStreamCell = LiveStreamCell.v_fromNib()
    
    private lazy var paginatedDataSource: PaginatedDataSource = {
        let dataSource = PaginatedDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    private(set) var visibleItems = NSOrderedSet()
    
    var delegate: VPaginatedDataSourceDelegate?
    
    var state: VDataSourceState {
        return paginatedDataSource.state
    }
    
    func removeDeletedItems() {
        paginatedDataSource.removeDeletedItems()
    }
    
    func loadPage(pageType: VPageType, completion: ((NSError?)->())? = nil ) {
        paginatedDataSource.loadPage(pageType,
            createOperation: {
                return LiveStreamOperation()
            },
            completion: { (operation, error) in
                completion?(error)
            }
        )
    }
    
    func refreshRemote(completion: (([AnyObject], NSError?)->())? = nil ) {
        paginatedDataSource.refreshRemote(
            createOperation: {
                return LiveStreamOperationUpdate()
            },
            completion: { (results, error) in
                completion?(results, error)
            }
        )
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        let sortedArray = (newValue.array as? [VLiveStreamModel] ?? []).sort { $0.displayOrder?.compare($1.displayOrder) == .OrderedDescending }
        visibleItems = NSOrderedSet(array: sortedArray)
        delegate?.paginatedDataSource( paginatedDataSource, didUpdateVisibleItemsFrom: oldValue, to: visibleItems )
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        delegate?.paginatedDataSource?( paginatedDataSource, didChangeStateFrom: oldState, to: newState)
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
        delegate?.paginatedDataSource( paginatedDataSource, didReceiveError: error)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func collectionView( collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {
        let identifier = LiveStreamCell.suggestedReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath)
        decorateCell(cell, forItemAtIndexPath: indexPath)
        return cell
    }
    
    // MARK: - VExtendedCollectionViewDataSource
    
    func decorateCell( cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let model = self.visibleItems[ indexPath.row ] as! VLiveStreamModel
        let cell = cell as! LiveStreamCell
        
        let aligner = StreamCellAligner(cell:cell)
        if model.username == "Patrick" {
            aligner.align( .Right )
        } else {
            aligner.align( .Left )
        }
        
        let font = UIFont.systemFontOfSize(18.0)
        let textColor = UIColor.whiteColor()
        let backgroundColor = UIColor.grayColor()
        cell.style = LiveStreamCell.Style(textColor: textColor, backgroundColor: backgroundColor, font: font)
        
        cell.viewData = LiveStreamCell.ViewData(text: model.text, createdAt: model.createdAt, username: model.username)
    }
    
    func registerCells( collectionView: UICollectionView ) {
        let identifier = LiveStreamCell.suggestedReuseIdentifier
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: LiveStreamCell.self) )
        collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        decorateCell( sizingCell, forItemAtIndexPath: indexPath)
        return sizingCell.cellSizeWithinBounds(collectionView.bounds)
    }
}
