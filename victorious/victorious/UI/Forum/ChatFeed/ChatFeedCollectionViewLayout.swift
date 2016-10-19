//
//  ChatFeedCollectionViewLayout.swift
//  victorious
//
//  Created by Tian Lan on 7/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A custom collection view layout for the chat feed which allows for inserting content at the top of the collection
/// view without affecting the content offset.
class ChatFeedCollectionViewLayout: UICollectionViewFlowLayout {
    /// Set this to the collection view's current content size before inserting cells at the top.
    var contentSizeWhenInsertingAbove: CGSize?
    
    override func prepare() {
        super.prepare()
        
        if let collectionView = collectionView, let oldContentSize = contentSizeWhenInsertingAbove {
            let newContentSize = collectionViewContentSize
            let contentOffsetY = collectionView.contentOffset.y + (newContentSize.height - oldContentSize.height)
            let newOffset = CGPoint(x: collectionView.contentOffset.x, y: contentOffsetY)
            
            // Occasionally, setting the content offset here will trigger the chat feed's unstashing behavior. For some
            // unknown reason, this causes a crash within UICollectionView, so we disable unstashing while we scroll
            // here. We should find a better way of maintaining the scroll position when inserting content at the top
            // of the collection view that doesn't have this problem.
            let chatFeedViewController = collectionView.delegate as? ChatFeedViewController
            chatFeedViewController?.unstashingViaScrollingIsEnabled = false
            collectionView.setContentOffset(newOffset, animated: false)
            chatFeedViewController?.unstashingViaScrollingIsEnabled = true
            
            contentSizeWhenInsertingAbove = nil
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return (super.layoutAttributesForElements(in: rect) ?? []).map {
            processLayoutAttributes($0)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        
        if let attributes = attributes {
            return processLayoutAttributes(attributes)
        }
        
        return attributes
    }
    
    /// Adjusts layout attributes to align messages to the bottom when there aren't enough to fill the entire
    /// collection view.
    private func processLayoutAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        guard let collectionView = collectionView else {
            return layoutAttributes
        }
        
        let contentSize = collectionViewContentSize
        let extraHeight = collectionView.bounds.height - contentSize.height - collectionView.contentInset.vertical
        
        if
            let modifiedLayoutAttributes = layoutAttributes.copy() as? UICollectionViewLayoutAttributes
            , extraHeight > 0.0
        {
            modifiedLayoutAttributes.frame.origin.y += extraHeight
            return modifiedLayoutAttributes
        }
        
        return layoutAttributes
    }
}
