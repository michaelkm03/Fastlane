//
//  CommentsDataSource.swift
//  victorious
//
//  Created by Michael Sena on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class CommentsDataSource : PaginatedDataSource, UICollectionViewDataSource {
    
    private let sequence: VSequence
    
    private let dependencyManager: VDependencyManager
    private var hasLoadedOnce: Bool = false
    
    private var registeredCommentReuseIdentifiers = Set<String>()
    
    let activityFooterDataSource = ActivityFooterCollectionDataSource()
    
    init(sequence: VSequence, dependencyManager: VDependencyManager) {
        self.sequence = sequence
        self.dependencyManager = dependencyManager
        super.init()
        
        self.KVOController.observe( self.sequence,
            keyPath: "comments",
            options: [],
            action: Selector("onCommentsChanged:")
        )
    }
    
    func onCommentsChanged( change: [NSObject : AnyObject]? ) {
        guard hasLoadedOnce, let value = change?[ NSKeyValueChangeKindKey ] as? UInt,
            let kind = NSKeyValueChange(rawValue:value) where kind != .Removal else {
                return
        }
        self.loadNewItems(
            createOperation: {
                let op = SequenceCommentsOperation(sequenceID: sequence.remoteId)
                op.localFetch = true
                return op
            },
            completion:nil
        )
    }
    
    func loadComments( pageType: VPageType, completion:(([AnyObject]?, NSError?)->())? = nil ) {
        self.loadPage( pageType,
            createOperation: {
                return SequenceCommentsOperation(sequenceID: self.sequence.remoteId)
            },
            completion: { (results, error) in
                self.hasLoadedOnce = true
                completion?(results, error)
            }
        )
    }
    
    func deleteSequence( completion: (([AnyObject]?, NSError?)->())? = nil ) {
        SequenceDeleteOperation(sequenceID: self.sequence.remoteId).queue() { (results, error) in
            completion?(results, error)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func registerCells(collectionView: UICollectionView) {
        activityFooterDataSource.registerCells(collectionView)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return visibleItems.count ?? 0
        } else {
            return activityFooterDataSource.collectionView(collectionView, numberOfItemsInSection: section)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let comment = visibleItems[indexPath.item] as! VComment
            let reuseIdentifierForComment = MediaAttachmentView.reuseIdentifierForComment(comment)
            if !registeredCommentReuseIdentifiers.contains(reuseIdentifierForComment) {
                collectionView.registerNib(VContentCommentsCell.nibForCell(), forCellWithReuseIdentifier: reuseIdentifierForComment)
                registeredCommentReuseIdentifiers.insert(reuseIdentifierForComment)
            }
            return collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifierForComment, forIndexPath: indexPath)
        } else {
            return activityFooterDataSource.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        return collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionFooter, withReuseIdentifier: "MediaSearchActivityFooter", forIndexPath: indexPath )
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            let comment = visibleItems[ indexPath.item ] as! VComment
            let size = VContentCommentsCell.sizeWithFullWidth( collectionView.bounds.width,
                comment: comment,
                hasMedia: (comment.commentMediaType() != .NoMedia),
                dependencyManager: dependencyManager
            )
            return CGSize(width: collectionView.bounds.width, height: size.height)
        } else {
            return activityFooterDataSource.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
        }
    }
}
