//
//  VListShelfCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A shelf that displays "list shelf" content along with some metadata.
/// Utilize subclasses for complete implementations.
class VListShelfCollectionViewCell: VBaseCollectionViewCell {
    
    struct Constants {
        static let separatorHeight: CGFloat = 4
        static let titleTopVerticalSpace: CGFloat = 11
        static let minimumTitleToDetailVerticalSpace: CGFloat = 5
        static let detailToCollectionViewVerticalSpace: CGFloat = 13
        static let contentHorizontalInset: CGFloat = 18
        
        static let interCellSpace: CGFloat = 2
        static let collectionViewSectionEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 11, bottom: 11, right: 11)
        
        static let baseHeight = separatorHeight + titleTopVerticalSpace + minimumTitleToDetailVerticalSpace + detailToCollectionViewVerticalSpace
        
        static let maxItemsCount = 7
        
        static let streamATFThresholdKey = "streamAtfViewThreshold"
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTopVerticalSpace: NSLayoutConstraint!
    @IBOutlet var horizontalEdgeConstraints: [NSLayoutConstraint]!
    @IBOutlet var minimumTitleToDetailSpaceConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var detailToCollectionViewSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    private var centeringInset: CGFloat = 0
    private var cellSideLength: CGFloat = 0
    private var expandedCellSideLength: CGFloat {
        return cellSideLength * 2 + Constants.interCellSpace
    }
    
    var trackingMinRequiredCellVisibilityRatio: CGFloat = 0.0
    
    let failureCellFactory: VNoContentCollectionViewCellFactory = VNoContentCollectionViewCellFactory(acceptableContentClasses: nil)
    
    /// The shelf whose content will populate this cell.
    var shelf: Shelf? {
        didSet {
            if oldValue == shelf {
                return
            }
            
            if let shelf = shelf as? ListShelf {
                for streamItem in shelf.streamItems {
                    collectionView.registerClass(VShelfContentCollectionViewCell.self, forCellWithReuseIdentifier: VShelfContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager))
                }
                
                detailLabel.text = shelf.caption
                titleLabel.text = shelf.title
            }
            collectionView.reloadData()
        }
    }
    
    /// The dependency manager that will be used to style this cell.
    var dependencyManager: VDependencyManager? {
        didSet {
            if oldValue == dependencyManager {
                return
            }
            
            if let dependencyManager = dependencyManager {
                dependencyManager.addBackgroundToBackgroundHost(self)
                
                separatorView.backgroundColor = dependencyManager.accentColor
                
                titleLabel.font = dependencyManager.titleFont
                detailLabel.font = dependencyManager.detailFont
                
                titleLabel.textColor = dependencyManager.textColor
                detailLabel.textColor = dependencyManager.textColor
                
                trackingMinRequiredCellVisibilityRatio = CGFloat(dependencyManager.numberForKey(Constants.streamATFThresholdKey).floatValue)
            }
        }
    }
    private let streamTrackingHelper = VStreamTrackingHelper()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCollectionViewSize()
    }
    
    private func updateCollectionViewSize() {
        let totalWidths = VListShelfCollectionViewCell.totalCellWidths(collectionView.bounds.width)
        cellSideLength = VListShelfCollectionViewCell.cellSideLength(totalWidths)
        let newCollectionViewHeight = VListShelfCollectionViewCell.collectionViewHeight(cellSideLength: cellSideLength)
        if ( collectionViewHeightConstraint.constant > newCollectionViewHeight ) {
            //The current cells we have are too big, reload before updating the constraint to avoid warnings
            collectionView.reloadSections(NSIndexSet(index: 0))
        }
        centeringInset = floor(totalWidths % cellSideLength) / 2
        collectionViewHeightConstraint.constant = VListShelfCollectionViewCell.collectionViewHeight(cellSideLength: cellSideLength)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private class func totalCellWidths(collectionViewWidth: CGFloat) -> CGFloat {
        let sectionInset = Constants.collectionViewSectionEdgeInsets
        return collectionViewWidth - sectionInset.left - sectionInset.right - (Constants.interCellSpace * 4)
    }
    
    private class func cellSideLength(totalCellWidths: CGFloat) -> CGFloat {
        return floor(totalCellWidths / 5)
    }
    
    private class func collectionViewHeight(cellSideLength length: CGFloat) -> CGFloat {
        let collectionViewSectionEdgeInsets = Constants.collectionViewSectionEdgeInsets
        let insetHeight = collectionViewSectionEdgeInsets.top + collectionViewSectionEdgeInsets.bottom
        let baseHeight = ceil(length * 2)
        return baseHeight + Constants.interCellSpace + insetHeight
    }
    
    /// The optimal size for this cell.
    ///
    /// - parameter collectionViewBounds: The bounds of the collection view containing this cell (minus any relevant insets)
    /// - parameter shelf: The shelf whose content will populate this cell
    /// - parameter dependencyManager: The dependency manager that will be used to style the cell
    ///
    /// - returns: The optimal size for this cell.
    class func desiredSize(collectionViewBounds: CGRect, shelf: ListShelf, dependencyManager: VDependencyManager) -> CGSize {
        let width = collectionViewBounds.width
        let length = cellSideLength(totalCellWidths(width))
        let collectionViewHeight = self.collectionViewHeight(cellSideLength: length)
        let height = Constants.baseHeight + collectionViewHeight
        return CGSizeMake(width, height)
    }
    
    // MARK: - View management
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for constraint in horizontalEdgeConstraints {
            constraint.constant = Constants.contentHorizontalInset
        }
        for constraint in minimumTitleToDetailSpaceConstraints {
            constraint.constant = Constants.minimumTitleToDetailVerticalSpace
        }
        titleTopVerticalSpace.constant = Constants.titleTopVerticalSpace
        separatorHeightConstraint.constant = Constants.separatorHeight
        detailToCollectionViewSpaceConstraint.constant = Constants.detailToCollectionViewVerticalSpace
        updateCollectionViewSize()
    }
}

extension VListShelfCollectionViewCell: TrackableShelf {
    
    func trackVisibleSequences() {
        for cell in collectionView.visibleCells() {
            if let indexPath = collectionView.indexPathForCell(cell),
               let shelf = shelf,
               let streamItem = streamItemAt(indexPath: indexPath) {
                let event = StreamCellContext(streamItem: streamItem, stream: shelf, fromShelf: false)
                streamTrackingHelper.onStreamCellDidBecomeVisibleWithCellEvent(event)
            }
        }
    }
    
    /// The stream item displayed at the provided index path.
    ///
    /// - parameter indexPath: The index path of the cell whose represented stream item is desired.
    ///
    /// - returns: The stream item displayed at the provided index path.
    func streamItemAt(indexPath indexPath: NSIndexPath) -> VStreamItem? {
        fatalError("Subclasses of VListShelfCollectionViewCell must override streamItemAtIndexPath:")
    }
}

extension VListShelfCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        fatalError("Subclasses of VListShelfCollectionViewCell must override collectionView:cellForItemAtIndexPath:")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("Subclasses of VListShelfCollectionViewCell must override collectionView:numberOfItemsInSection:")
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
}

extension VListShelfCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        var insets = Constants.collectionViewSectionEdgeInsets
        insets.right += centeringInset
        insets.left += centeringInset
        return insets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interCellSpace
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interCellSpace
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var side = cellSideLength
        if indexPath.row == 0 {
            side = expandedCellSideLength
        }
        return CGSizeMake(side, side)
    }
    
}

extension VListShelfCollectionViewCell: VBackgroundContainer {
    
    func backgroundContainerView() -> UIView {
        return contentView
    }
    
}

private extension VDependencyManager {
    
    var titleFont: UIFont {
        return fontForKey(VDependencyManagerHeaderFontKey)
    }
    
    var detailFont: UIFont {
        return fontForKey(VDependencyManagerLabel3FontKey)
    }
    
    var textColor: UIColor {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var accentColor: UIColor {
        return colorForKey(VDependencyManagerAccentColorKey)
    }
    
}
