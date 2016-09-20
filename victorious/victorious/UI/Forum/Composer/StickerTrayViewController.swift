//
//  StickerTrayViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import MBProgressHUD

class StickerTrayViewController: UIViewController, Tray, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private struct Constants {
        static let collectionViewContentInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        static let numberOfRows = 2
        static let interItemSpace = CGFloat(2)
    }
    
    weak var delegate: TrayDelegate?
    var progressHUD: MBProgressHUD?
    var mediaExporter: MediaSearchExporter?
    
    lazy var dataSource: StickerTrayDataSource = {
        let dataSource = StickerTrayDataSource(dependencyManager: self.dependencyManager)
        dataSource.dataSourceDelegate = self
        return dataSource
    }()
    
    @IBOutlet private(set) var collectionView: UICollectionView!
    
    private var dependencyManager: VDependencyManager!
    
    static func new(dependencyManager: VDependencyManager) -> StickerTrayViewController {
        let tray = StickerTrayViewController.v_initialViewControllerFromStoryboard() as StickerTrayViewController
        tray.dependencyManager = dependencyManager
        return tray
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.fetchStickers()
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
            let remoteID = gif.remoteID
            else {
                Log.debug("Selected asset from an unexpected index in Tray")
                return
        }
        showExportingHUD()
        exportMedia(fromSearchResult: gif) { [weak self] state in
            self?.dismissHUD()
            switch state {
            case .success(let result):
                let localAssetParameters = ContentMediaAsset.LocalAssetParameters(contentType: .gif, remoteID: remoteID, source: nil, size: gif.assetSize, url: gif.sourceMediaURL)
                guard
                    let strongSelf = self,
                    let asset = ContentMediaAsset(initializationParameters: localAssetParameters),
                    let previewImage = result.exportPreviewImage
                    else {
                        return
                }
                strongSelf.delegate?.tray(strongSelf, selectedAsset: asset, withPreviewImage: previewImage)
            case .failure(let error):
                self?.showHUD(renderingError: error)
            case .canceled:()
            }
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let _ = dataSource.asset(atIndex: indexPath.row) else {
            return CGSize.zero
        }
        let numberOfRows = Constants.numberOfRows
        let emptySpace = Constants.collectionViewContentInsets.vertical + CGFloat(Constants.numberOfRows - 1) * Constants.interItemSpace
        let side = (view.bounds.height / CGFloat(numberOfRows)) - emptySpace
        return CGSize(width: side, height: side)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return Constants.collectionViewContentInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
}
