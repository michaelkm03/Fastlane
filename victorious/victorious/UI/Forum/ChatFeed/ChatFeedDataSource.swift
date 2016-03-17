//
//  ChatFeedDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK
import KVOController

class ChatFeedDataSource: PaginatedDataSource, UICollectionViewDataSource {
    
    private let itemsPerPage = 10
    
    /// If this interval is too small, the scrolling animations will become choppy
    /// as they step on each other before finishing.
    private var fetchMessageInterval: NSTimeInterval = 3.5
    
    private var timerManager: VTimerManager?
    
    let dependencyManager: VDependencyManager
    
    let cellDecorator = MessageCellDecorator()
    let sizingCell: MessageCell = MessageCell.v_fromNib()
    
    init( dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
        super.init()
        
        super.maximumVisibleItemsCount = 50
    }
    
    func refreshRemote() {
        loadNewItems(
            createOperation: {
                let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: itemsPerPage)
                return DequeueMessagesOperation(paginator: paginator)
            },
            completion: nil
        )
    }
    
    // MARK: - Live Update
    
    func beginLiveUpdates() {
        guard timerManager == nil else {
            return
        }
        timerManager = VTimerManager.addTimerManagerWithTimeInterval(fetchMessageInterval,
            target: self,
            selector: Selector("refreshRemote"),
            userInfo: nil,
            repeats: true, 
            toRunLoop: NSRunLoop.mainRunLoop(),
            withRunMode: NSRunLoopCommonModes)
    }
    
    func endLiveUpdates() {
        timerManager?.invalidate()
        timerManager = nil
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleItems.count
    }
    
    func collectionView( collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath ) -> UICollectionViewCell {
        let identifier = MessageCell.suggestedReuseIdentifier
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! MessageCell
        let message = visibleItems[ indexPath.row ] as! ChatMessage
        cellDecorator.decorateCell(cell, withMessage: message, dependencyManager: dependencyManager.fanCellDependency)
        return cell
    }
    
    func registerCellsWithCollectionView( collectionView: UICollectionView ) {
        let identifier = MessageCell.suggestedReuseIdentifier
        let nib = UINib(nibName: identifier, bundle: NSBundle(forClass: MessageCell.self) )
        collectionView.registerNib(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let message = visibleItems[ indexPath.row ] as! ChatMessage
        var bounds = sizingCell.bounds
        bounds.size.width = collectionView.bounds.width
        sizingCell.bounds = bounds
        cellDecorator.decorateCell(sizingCell, withMessage: message, dependencyManager: dependencyManager.fanCellDependency)
        return sizingCell.cellSizeWithinBounds(collectionView.bounds)
    }
    
    func redecorateVisibleCells(collectionView: UICollectionView) {
        for indexPath in collectionView.indexPathsForVisibleItems() {
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MessageCell
            let message = visibleItems[ indexPath.row ] as! ChatMessage
            cellDecorator.decorateCell(cell, withMessage:message, dependencyManager: dependencyManager.fanCellDependency)
        }
    }
}

private extension VDependencyManager {
    
    var fanCellDependency: VDependencyManager {
        let configuration = templateValueOfType(NSDictionary.self, forKey: "cell.fan") as! [NSObject: AnyObject]
        return self.childDependencyManagerWithAddedConfiguration(configuration)
    }
    
    var creatorCellDependency: VDependencyManager {
        let configuration = templateValueOfType(NSDictionary.self, forKey: "cell.creator") as! [NSObject: AnyObject]
        return self.childDependencyManagerWithAddedConfiguration(configuration)
    }
}
