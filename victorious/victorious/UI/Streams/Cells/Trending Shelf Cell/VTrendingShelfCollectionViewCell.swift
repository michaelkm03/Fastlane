//
//  VTrendingShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A shelf that displays a list of trending content along with some metadata.
/// Utilize subclasses for implementations.
class VTrendingShelfCollectionViewCell: VBaseCollectionViewCell {
    
    private let kLoggedInChangedNotification = "com.getvictorious.LoggedInChangedNotification"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var followControl: VFollowControl? {
        didSet {
            followControl?.tintUnselectedImage = true
            
            if AgeGate.isAnonymousUser() {
                followControl?.removeFromSuperview()
                followControl = nil
            }
        }
    }
    
    lazy var streamItemVisibilityTrackingHelper: ShelfVisibilityTrackingHelper = {
        return ShelfVisibilityTrackingHelper(collectionView: self.collectionView)
    }()
    
    private let failureCellFactory = VNoContentCollectionViewCellFactory(acceptableContentClasses: nil)
    
    var shelf: Shelf? {
        didSet {
            if oldValue == shelf {
                return
            }
            
            streamItemVisibilityTrackingHelper.shelf = shelf
            
            if let items = shelf?.streamItems,
                let streamItems = items.array as? [VStreamItem] {
                    for (index, streamItem) in streamItems.enumerate() {
                        if index == streamItems.count - 1 {
                            
                            let reuseIdentifier = VTrendingShelfContentSeeAllCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
                            collectionView.registerClass(VTrendingShelfContentSeeAllCell.self, forCellWithReuseIdentifier: reuseIdentifier)
                            
                        }
                        else {
                            
                            let reuseIdentifier = VShelfContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
                            collectionView.registerClass(VShelfContentCollectionViewCell.self, forCellWithReuseIdentifier:reuseIdentifier)
                            
                        }
                    }
            }
            updateFollowControlState()
            self.collectionView.reloadData()
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if oldValue == dependencyManager {
                return
            }
            
            if let dependencyManager = dependencyManager {
                followControl?.dependencyManager = dependencyManager
                streamItemVisibilityTrackingHelper.trackingMinRequiredCellVisibilityRatio = dependencyManager.minTrackingRequiredCellVisibilityRatio
                dependencyManager.addBackgroundToBackgroundHost(self)
            }
        }
    }
    
    /// Override in subclasses to update the follow button at the proper times
    func updateFollowControlState() {}
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loginStatusDidChange"), name: kLoggedInChangedNotification, object: VObjectManager.sharedManager())
    }
    
    /// Nils out shelf to respond to changes in login, should not be called except in response to a login change.
    func loginStatusDidChange() {
        shelf = nil
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        trackVisibleSequences()
    }
    
    override func prepareForReuse() {
        collectionView.contentOffset = CGPoint.zero
    }
    
}

extension VTrendingShelfCollectionViewCell: TrackableShelf {

    func trackVisibleSequences() {
        streamItemVisibilityTrackingHelper.trackVisibleSequences()
    }
}

extension VTrendingShelfCollectionViewCell : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let streamItems = shelf?.streamItems.array as? [VStreamItem] {
            let streamItem = streamItems[indexPath.row]
            let isShowMoreCell = indexPath.row == streamItems.count - 1
            let T = isShowMoreCell ? VTrendingShelfContentSeeAllCell.self : VShelfContentCollectionViewCell.self
            let identifier = T.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
            let cell: VShelfContentCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! VShelfContentCollectionViewCell
            cell.streamItem = streamItem
            cell.dependencyManager = dependencyManager
            return cell
        }
        assertionFailure("VTrendingShelfCollectionViewCell was asked to display an object that isn't a stream item.")
        failureCellFactory.registerNoContentCellWithCollectionView(collectionView)
        return failureCellFactory.noContentCellForCollectionView(collectionView, atIndexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shelf?.streamItems.count ?? 0
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
}

extension VTrendingShelfCollectionViewCell: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let responder: VShelfStreamItemSelectionResponder = typedResponder()
        if let shelf = shelf, let streamItem = shelf.streamItems[indexPath.row] as? VStreamItem {
            if indexPath.row == shelf.streamItems.count - 1 {
                responder.navigateTo(nil, fromShelf: shelf)
            }
            else {
                responder.navigateTo(streamItem, fromShelf: shelf)
            }
            return
        }
        assertionFailure("VTrendingShelfCollectionViewCell selected an invalid stream item")
    }
    
}

extension VTrendingShelfCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 11, 11, 11)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(89, 89)
    }
    
}

extension VTrendingShelfCollectionViewCell: VBackgroundContainer {
    
    func backgroundContainerView() -> UIView {
        return contentView
    }
}

extension VDependencyManager {
    
    var minTrackingRequiredCellVisibilityRatio: CGFloat {
        return numberForKey("streamAtfViewThreshold") as CGFloat
    }
}
