//
//  TrendingTopicShelfCollectionViewCell.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class TrendingTopicShelfCollectionViewCell: VBaseCollectionViewCell {
    
    private struct Constants {
        static let overLabelSpace: CGFloat = 12
        static let underLabelSpace: CGFloat = 12
        static let contentInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
    }
    
    // MARK: Properties
    
    private let renderedTextPostCache = NSCache()
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = Constants.contentInsets
        flowLayout.itemSize = TrendingTopicContentCollectionViewCell.desiredSize()
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var streamItemVisibilityTrackingHelper: ShelfVisibilityTrackingHelper = {
        return ShelfVisibilityTrackingHelper(collectionView: self.collectionView)
    }()
    
    var shelf: Shelf? {
        didSet {
            if shelf == oldValue,
                let newStreamItems = shelf?.streamItems,
                let oldStreamItems = oldValue?.streamItems
                where newStreamItems == oldStreamItems {
                    //The shelf AND its content are the same, no need to update
                    return
            }
            
            if let shelf = shelf {
                label.text = shelf.title
                streamItemVisibilityTrackingHelper.shelf = shelf
                collectionView.reloadData()
            }
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if dependencyManager == oldValue {
                return
            }
            
            if let dependencyManager = dependencyManager {
                dependencyManager.addBackgroundToBackgroundHost(self)
                label.font = dependencyManager.titleFont
                label.textColor = dependencyManager.titleColor
                streamItemVisibilityTrackingHelper.trackingMinRequiredCellVisibilityRatio = dependencyManager.minTrackingRequiredCellVisibilityRatio
            }
        }
    }
    
    // MARK: setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        // Add subviews
        contentView.addSubview(label)
        contentView.addSubview(collectionView)
        
        // Setup constraints
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-topSpace-[label]-bottomSpace-[collectionView(height)]", options: [], metrics: ["height": TrendingTopicContentCollectionViewCell.desiredSize().height, "topSpace": Constants.overLabelSpace, "bottomSpace": Constants.underLabelSpace], views: ["label": label, "collectionView": collectionView]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: [], metrics: nil, views: ["collectionView": collectionView]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-lspace-[label]-rspace-|", options: [], metrics: ["lspace": Constants.contentInsets.left, "rspace": Constants.contentInsets.right], views: ["label": label]))
        
        // Register trending topic content cell
        collectionView.registerClass(TrendingTopicContentCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TrendingTopicContentCollectionViewCell.self))
    }
    
    /// The optimal size for this cell.
    ///
    /// :param: bounds The bounds of the collection view containing this cell (minus any relevant insets)
    /// :param: shelf The shelf whose content will populate this cell
    /// :param: dependencyManager The dependency manager that will be used to style the cell
    ///
    /// :return: The optimal size for this cell.
    class func desiredSize(collectionViewBounds bounds: CGRect, shelf: Shelf, dependencyManager: VDependencyManager) -> CGSize {
        
        //Add the height of the labels to find the entire height of the cell
        let titleHeight = shelf.title.frameSizeForWidth(CGFloat.max, andAttributes: [NSFontAttributeName : dependencyManager.titleFont]).height
        let totalTitleHeight = titleHeight + Constants.underLabelSpace + Constants.overLabelSpace
        let totalHeight = totalTitleHeight + TrendingTopicContentCollectionViewCell.desiredSize().height
        
        return CGSize(width: bounds.width, height: totalHeight)
    }
    
    // MARK: Scroll Delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        streamItemVisibilityTrackingHelper.trackVisibleSequences()
    }
}

extension TrendingTopicShelfCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shelf?.streamItems.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let streamItems = shelf?.streamItems as? [VSequence] {
            let streamItem = streamItems[indexPath.row]
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TrendingTopicContentCollectionViewCell.reuseIdentifier(), forIndexPath: indexPath) as! TrendingTopicContentCollectionViewCell
            cell.renderedTextPostCache = renderedTextPostCache
            cell.sequence = streamItem
            cell.dependencyManager = dependencyManager
            return cell
        }
        assertionFailure("TrendingTopicShelfCollectionViewCell was asked to display an object that isn't a stream item.")
        return UICollectionViewCell()
    }
}

extension TrendingTopicShelfCollectionViewCell: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        
        let responder: VHashtagSelectionResponder = typedResponder()
        if let streamItems = shelf?.streamItems as? [VSequence] {
            let streamItem = streamItems[indexPath.row]
            let hashtag = streamItem.trendingTopicName ?? ""
            responder.hashtagSelected(hashtag)
            return
        }
        assertionFailure("VTrendingShelfCollectionViewCell selected an invalid stream item")
    }
}

extension TrendingTopicShelfCollectionViewCell: VBackgroundContainer {
    
    func backgroundContainerView() -> UIView {
        return contentView
    }
}

private extension VDependencyManager {
    
    var titleFont: UIFont {
        return fontForKey(VDependencyManagerHeading3FontKey)
    }
    
    var titleColor: UIColor {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
}
