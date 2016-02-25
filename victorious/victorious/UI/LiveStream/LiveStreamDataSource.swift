//
//  LiveStreamDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK
import KVOController

@objc protocol LiveStreamDataSourceDelegate: VPaginatedDataSourceDelegate {
    func liveStreamDataSourceDidUpdateStashedItems( liveStreamDataSource: LiveStreamDataSource)
}

class LiveStreamDataSource: NSObject, UICollectionViewDataSource, VPaginatedDataSourceDelegate {
    
    static var liveUpdateFrequency: NSTimeInterval = 5.0
    
    let sizingCell: VMessageCollectionCell = VMessageCollectionCell.v_fromNib()
    
    let cellDecorator: MessageCollectionCellDecorator
    
    private lazy var paginatedDataSource: PaginatedDataSource = {
        let dataSource = PaginatedDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    
    private(set) var stashedItems = NSOrderedSet() {
        didSet {
            self.delegate?.liveStreamDataSourceDidUpdateStashedItems(self)
        }
    }
    
    private(set) var visibleItems = NSOrderedSet()
    
    func isLoading() -> Bool {
        return self.paginatedDataSource.isLoading()
    }
    
    var delegate: LiveStreamDataSourceDelegate?
    
    var state: VDataSourceState {
        return self.paginatedDataSource.state
    }
    
    func removeDeletedItems() {
        self.paginatedDataSource.removeDeletedItems()
    }
    
    var shouldStashNewContent: Bool = false {
        didSet {
            if !shouldStashNewContent && stashedItems.count > 0 {
                let oldValue = visibleItems
                visibleItems = NSOrderedSet(array: oldValue.array + stashedItems.array)
                self.delegate?.paginatedDataSource( paginatedDataSource, didUpdateVisibleItemsFrom: oldValue, to: visibleItems)
                stashedItems = NSOrderedSet()
            }
        }
    }
    
    let dependencyManager: VDependencyManager
    let conversation: VConversation
    
    let messageCellDecorator: MessageTableCellDecorator
    
    init( conversation: VConversation, dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
        self.conversation = conversation
        self.messageCellDecorator = MessageTableCellDecorator(dependencyManager: dependencyManager)
        self.cellDecorator = MessageCollectionCellDecorator(dependencyManager: dependencyManager)
    }
    
    func loadMessages( pageType pageType: VPageType, completion:(([AnyObject]?, NSError?)->())? = nil ) {
        
        let conversationID = self.conversation.remoteId!.integerValue
        self.paginatedDataSource.loadPage( pageType,
            createOperation: {
                return LiveStreamOperation(conversationID: conversationID)
            },
            completion: { (results, error) in
                completion?( results, error)
            }
        )
    }
    
    func refreshRemote( completion:(([AnyObject]?, NSError?)->())? = nil) {
        
        let conversationID = self.conversation.remoteId!.integerValue
        self.paginatedDataSource.refreshRemote(
            createOperation: {
                return LiveStreamOperationUpdate(conversationID: conversationID)
            },
            completion: completion
        )
    }
    
    func purgeVisibleItemsWithinLimit(limit: Int) {
        paginatedDataSource.purgeVisibleItemsWithinLimit(limit)
    }
    
    // MARK: - VPaginatedDataSourceDelegate
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didUpdateVisibleItemsFrom oldValue: NSOrderedSet, to newValue: NSOrderedSet) {
        
        let sortedArray = (newValue.array as? [VMessage] ?? []).sort { $0.displayOrder.compare($1.displayOrder) == .OrderedDescending }
        
        if !shouldStashNewContent {
            self.visibleItems = NSOrderedSet(array: sortedArray)
            self.delegate?.paginatedDataSource( paginatedDataSource, didUpdateVisibleItemsFrom: oldValue, to: visibleItems)
        
        } else {
            let existing = self.stashedItems.array
            let new = sortedArray.filter { !oldValue.containsObject($0) }
            self.stashedItems = NSOrderedSet(array: existing + new)
        }
    }
    
    func paginatedDataSource( paginatedDataSource: PaginatedDataSource, didChangeStateFrom oldState: VDataSourceState, to newState: VDataSourceState) {
        self.delegate?.paginatedDataSource?( paginatedDataSource, didChangeStateFrom: oldState, to: newState)
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didReceiveError error: NSError) {
        self.delegate?.paginatedDataSource( paginatedDataSource, didReceiveError: error)
    }
    
    func paginatedDataSource(paginatedDataSource: PaginatedDataSource, didPurgeItems items: NSOrderedSet) {
        self.visibleItems = paginatedDataSource.visibleItems
        self.delegate?.paginatedDataSource?( paginatedDataSource, didPurgeItems: items)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func collectionView( collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {
        let identifier = VMessageCollectionCell.suggestedReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! VMessageCollectionCell
        let message = visibleItems[ indexPath.row ] as! VMessage
        cellDecorator.decorateCell(cell, withMessage: message)
        return cell
    }
    
    func registerCellsWithCollectionView( collectionView: UICollectionView ) {
        let identifier = VMessageCollectionCell.suggestedReuseIdentifier
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: VMessageCollectionCell.self) )
        collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let message = visibleItems[ indexPath.row ] as! VMessage
        cellDecorator.decorateCell(sizingCell, withMessage: message)
        return sizingCell.cellSizeWithinBounds(collectionView.bounds)
    }
    
    func redocorateVisibleCells(collectionView: UICollectionView) {
        for indexPath in collectionView.indexPathsForVisibleItems() {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! VMessageCollectionCell
            let message = visibleItems[ indexPath.row ] as! VMessage
            cellDecorator.decorateCell(cell, withMessage:message)
        }
    }
}

struct MessageCollectionCellDecorator {
    
    let dependencyManager: VDependencyManager
    
    func decorateCell( cell: VMessageCollectionCell, withMessage message: VMessage) {
        let aligner = StreamCellAligner(cell:cell)
        /*if message.sender == VCurrentUser.user() {
            aligner.align( .Right )
        } else {
            aligner.align( .Left )
        }*/
        
        cell.style = VMessageCollectionCell.Style(
            textColor: UIColor.v_colorFromHexString("b294ca"),
            backgroundColor: UIColor.v_colorFromHexString("1b1c34"),
            font: UIFont.systemFontOfSize(16.0))
        
        cell.viewData = VMessageCollectionCell.ViewData(
            text: "\(message.displayOrder): \(message.text ?? "")",
            createdAt: message.postedAt,
            username: message.sender.name ?? ""
        )
    }
}
