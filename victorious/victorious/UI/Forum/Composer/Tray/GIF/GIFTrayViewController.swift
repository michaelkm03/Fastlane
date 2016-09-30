//
//  GIFTrayViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import MBProgressHUD

/// A view controller that displays a side-scrolling single-row of gifs that play in-line
class GIFTrayViewController: UIViewController, Tray, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LoadingCancellableViewDelegate {
    private struct Constants {
        static let collectionViewContentInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        static let interItemSpace = CGFloat(2)
    }
    
    weak var delegate: TrayDelegate?
    private(set) var progressHUD: MBProgressHUD?
    private(set) var mediaExporter: MediaSearchExporter?
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.fetchGifs()
        collectionView.hidden = false
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
            let remoteID = gif.remoteID where
            dataSource.trayState == .Populated
        else {
            if let _ = collectionView.cellForItemAtIndexPath(indexPath) as? TrayRetryLoadCollectionViewCell {
                dataSource.fetchGifs()
            }
            else {
                Log.debug("Selected asset from an unexpected index in Tray")
            }
            return
        }
        progressHUD = showExportingHUD(delegate: self)
        mediaExporter?.cancelDownload()
        mediaExporter = nil
        let exporter = exportMedia(fromSearchResult: gif) { [weak self] state in
            switch state {
                case .success(let result):
                    self?.progressHUD?.hide(true)
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
                    self?.progressHUD?.hide(true)
                    self?.showHUD(forRenderingError: error)
                case .canceled:()
            }
        }
        mediaExporter = exporter
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard
            let gif = dataSource.asset(atIndex: indexPath.row) where
            dataSource.trayState == .Populated
        else {
            return view.bounds.insetBy(Constants.collectionViewContentInsets).size
        }
        let height = view.bounds.height - Constants.collectionViewContentInsets.vertical
        return CGSize(width: height * gif.aspectRatio, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return Constants.collectionViewContentInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
    
    // MARK: - LoadingCancellableViewDelegate
    
    func cancel() {
        progressHUD?.hide(true)
        self.mediaExporter?.cancelDownload()
    }
}