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
        static let collectionViewHeight: CGFloat = 90
        static let overLabelSpace: CGFloat = 12
        static let underLabelSpace: CGFloat = 12
        static let contentInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
    }
    
    // MARK: Properties
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.sectionInset = Constants.contentInsets
        flowLayout.itemSize = CGSize(width: Constants.collectionViewHeight, height: Constants.collectionViewHeight)
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return collectionView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        return label
    }()
    
    var shelf: Shelf? {
        didSet {
            if ( shelf == oldValue ) {
                if let newStreamItems = streamItems(shelf), let oldStreamItems = streamItems(oldValue) {
                    if newStreamItems.isEqualToOrderedSet(oldStreamItems) {
                        //The shelf AND its content are the same, no need to update
                        return
                    }
                }
            }
            
            if let shelf = shelf {
                label.text = shelf.title
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
            }
        }
    }
    
    // MARK: setup
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        // Add subviews
        self.contentView.addSubview(label)
        self.contentView.addSubview(collectionView)
        
        // Setup constraints
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-topSpace-[label]-bottomSpace-[collectionView(height)]|", options: nil, metrics: ["height" : Constants.collectionViewHeight, "topSpace" : Constants.overLabelSpace, "bottomSpace" : Constants.underLabelSpace], views: ["label" : label, "collectionView" : collectionView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: ["collectionView" : collectionView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-lspace-[label]-rspace-|", options: nil, metrics: ["lspace" : Constants.contentInsets.left, "rspace" : Constants.contentInsets.right], views: ["label" : label]))
        
        // Register trending topic content cell
        collectionView.registerClass(TrendingTopicContentCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TrendingTopicContentCollectionViewCell.self))
    }
    
    //MARK: Helpers
    
    private func streamItems(shelf: Shelf?) -> NSOrderedSet? {
        return shelf?.streamItems
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
        let totalHeight = totalTitleHeight + Constants.collectionViewHeight
        
        return CGSize(width: bounds.width, height: totalHeight)
    }
}

extension TrendingTopicShelfCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streamItems(shelf)?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let streamItems = streamItems(shelf)?.array as? [VStreamItem] {
            let streamItem = streamItems[indexPath.row]
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(TrendingTopicContentCollectionViewCell.reuseIdentifier(), forIndexPath: indexPath) as! TrendingTopicContentCollectionViewCell
            cell.streamItem = streamItem
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
        if let shelf = shelf, streamItems = streamItems(shelf)?.array as? [VStreamItem] {
            let streamItem = streamItems[indexPath.row]
            let hashtag = streamItem.name ?? ""
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
        return fontForKey(VDependencyManagerHeading2FontKey)
    }
    
    var titleColor: UIColor {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
}
