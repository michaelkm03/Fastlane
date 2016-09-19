//
//  GIFTrayViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class GIFTrayViewController: UIViewController, Tray, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private struct Constants {
        static let collectionViewContentInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
    
    weak var delegate: TrayDelegate?
    
    lazy var dataSource: GIFTrayDataSource = {
        let dataSource = GIFTrayDataSource(dependencyManager: self.dependencyManager)
        dataSource.dataSourceDelegate = self
        return dataSource
    }()
    
    @IBOutlet private(set) var collectionView: UICollectionView!
    
    private var dependencyManager: VDependencyManager!
    
    static func new(dependencyManager: VDependencyManager) -> GIFTrayViewController {
        let tray = GIFTrayViewController.v_initialViewControllerFromStoryboard() as GIFTrayViewController
        tray.dependencyManager = dependencyManager
        return tray
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.fetchGifs()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.registerCells(withCollectionView: collectionView)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard
            let gif = dataSource.asset(atIndex: indexPath.item),
            let previewImage = gif.exportPreviewImage,
            let mediaURL = gif.sourceMediaURL
        else {
            return
        }
        delegate?.tray(self, selectedItemWithPreviewImage: previewImage, mediaURL: mediaURL)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let gif = dataSource.asset(atIndex: indexPath.row) else {
            return CGSize.zero
        }
        let height = view.bounds.height - Constants.collectionViewContentInsets.vertical
        return CGSize(width: height * gif.aspectRatio, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return Constants.collectionViewContentInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
}
