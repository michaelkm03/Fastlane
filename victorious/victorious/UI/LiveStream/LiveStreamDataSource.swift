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

class LiveStreamDataSource: PaginatedDataSource, UICollectionViewDataSource {
    
    let itemsPerPage = 15
    let maxVisibleItems = 45
    
    var currentPageType: VPageType?
    
    let dependencyManager: VDependencyManager
    let conversation: VConversation
    
    let cellDecorator: MessageCollectionCellDecorator
    let sizingCell: VMessageCollectionCell = VMessageCollectionCell.v_fromNib()
    
    init( conversation: VConversation, dependencyManager: VDependencyManager ) {
        self.dependencyManager = dependencyManager
        self.conversation = conversation
        self.cellDecorator = MessageCollectionCellDecorator(dependencyManager: dependencyManager)
    }
    
    func paginatorForPageType(pageType: VPageType) -> StandardPaginator? {
        let pageDisplayOrder: Int?
        switch pageType {
        case .Next:
            pageDisplayOrder = (visibleItems.lastObject as? PaginatedObjectType)?.displayOrder.integerValue
        case .Previous:
            pageDisplayOrder = (visibleItems.firstObject as? PaginatedObjectType)?.displayOrder.integerValue
        default:
            pageDisplayOrder = nil
        }
        
        guard let displayOrder = pageDisplayOrder,
            let paginator = StandardPaginator(displayOrder: displayOrder, pageType: pageType, itemsPerPage: itemsPerPage) else {
                return nil
        }
        return paginator
    }
    
    func loadUnstashedPage( pageType: VPageType, completion:(([AnyObject]?, NSError?)->())? = nil ) {
        
        guard let paginator = paginatorForPageType(pageType) else {
            return
        }
        
        currentPageType = pageType
        
        let conversationID = self.conversation.remoteId!.integerValue
        if let op = currentPaginatedRequestOperation as? FetcherOperation where op.results?.count > 0 {
            self.loadPage( pageType,
                createOperation: {
                    return LiveStreamOperation(conversationID: conversationID, paginator: paginator)
                },
                completion: { (results, error) in
                    completion?(results, error)
                    self.currentPageType = nil
                }
            )
        } else {
            self.loadPage( .First,
                createOperation: {
                    return LiveStreamOperation(conversationID: conversationID, paginator: paginator)
                },
                completion: { (results, error) in
                    completion?(results, error)
                    self.currentPageType = nil
                }
            )
        }
    }
    
    func loadMessages( pageType pageType: VPageType, completion:(([AnyObject]?, NSError?)->())? = nil ) {
        let conversationID = self.conversation.remoteId!.integerValue
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: itemsPerPage)
        
        self.loadPage( pageType,
            createOperation: {
                return LiveStreamOperation(conversationID: conversationID, paginator: paginator)
            },
            completion: completion
        )
    }
    
    func refreshRemote( completion:(([AnyObject]?, NSError?)->())? = nil) {
        
        let conversationID = self.conversation.remoteId!.integerValue
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: itemsPerPage)
        
        self.refreshRemote(
            createOperation: {
                return LiveStreamOperationUpdate(conversationID: conversationID, paginator: paginator)
            },
            completion: completion
        )
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
