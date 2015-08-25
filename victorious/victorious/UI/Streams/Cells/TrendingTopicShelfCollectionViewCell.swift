//
//  TrendingTopicShelfCollectionViewCell.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class TrendingTopicShelfCollectionViewCell: VBaseCollectionViewCell {
    
    private let collectionViewHeight = 90
    private let contentInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.itemSize = CGSize(width: 90, height: 90)
        flowLayout.sectionInset = self.contentInsets
        flowLayout.itemSize = CGSize(width: self.collectionViewHeight, height: self.collectionViewHeight)
        return flowLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Trending Topics"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        self.backgroundColor = UIColor.whiteColor()
        
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(label)
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(collectionView)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label][collectionView(height)]|", options: nil, metrics: ["height" : collectionViewHeight], views: ["label" : label, "collectionView" : collectionView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: ["collectionView" : collectionView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-lspace-[label]-rspace-|", options: nil, metrics: ["lspace" : contentInsets.left, "rspace" : contentInsets.right], views: ["label" : label]))
        
        // WARNING: Testing
        collectionView.registerClass(TrendingTopicContentCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
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
            onShelfSet()
            collectionView.reloadData()
        }
    }
    
    private func onShelfSet() {
        if let streamItems = streamItems(shelf)?.array as? [VStreamItem] {
            for (index, streamItem) in enumerate(streamItems) {
                 collectionView.registerClass(TrendingTopicContentCollectionViewCell.self, forCellWithReuseIdentifier: TrendingTopicContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager))
            }
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if dependencyManager == oldValue {
                return
            }
            
            if let dependencyManager = dependencyManager {
                self.label.font = dependencyManager.titleFont
            }
        }
    }
    
    private func streamItems(shelf: Shelf?) -> NSOrderedSet? {
        return shelf?.streamItems
    }
}

extension TrendingTopicShelfCollectionViewCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streamItems(shelf)?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let streamItems = streamItems(shelf)?.array as? [VStreamItem] {
            let streamItem = streamItems[indexPath.row]
            let reuseIdentifier = TrendingTopicContentCollectionViewCell.reuseIdentifierForStreamItem(streamItem, baseIdentifier: nil, dependencyManager: dependencyManager)
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TrendingTopicContentCollectionViewCell
            cell.streamItem = streamItem
            cell.dependencyManager = dependencyManager
            return cell
        }
        assertionFailure("TrendingTopicShelfCollectionViewCell was asked to display an object that isn't a stream item.")
        return UICollectionViewCell()
    }
}

extension TrendingTopicShelfCollectionViewCell: UICollectionViewDelegate {
    
}

private extension VDependencyManager {
    
    var titleFont: UIFont {
        return fontForKey(VDependencyManagerLabel1FontKey)
    }
    
    var titleColor: UIColor {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var topicFont: UIFont {
        return fontForKey(VDependencyManagerLabel2FontKey)
    }
}
