//
//  StickerTrayViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import MBProgressHUD
import VictoriousIOSSDK

/// A view controller that displays a side-scrolling double-row of stickers

class StickerTrayViewController: UIViewController, Tray, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private struct Constants {
        static let padding = CGFloat(5)
        static let collectionViewContentInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        static let numberOfRows = 2
        static let interItemSpace = padding
    }
    
    weak var delegate: TrayDelegate?

    var cellSize: CGSize = .zero {
        didSet {
            self.dataSource.cellSize = cellSize
            self.collectionView.reloadData()
        }
    }
    private(set) var progressHUD: MBProgressHUD?
    private(set) var mediaExporter: MediaSearchExporter?
    
    lazy var dataSource: StickerTrayDataSource = {
        let dataSource = StickerTrayDataSource(dependencyManager: self.dependencyManager)
        dataSource.dataSourceDelegate = self
        return dataSource
    }()
    
    @IBOutlet fileprivate(set) var collectionView: UICollectionView!
    
    fileprivate var dependencyManager: VDependencyManager!
    
    static func new(withDependencyManager dependencyManager: VDependencyManager) -> StickerTrayViewController {
        let tray = StickerTrayViewController.v_initialViewControllerFromStoryboard() as StickerTrayViewController
        tray.dependencyManager = dependencyManager
        return tray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.fetchStickers()
        collectionView.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let emptySpace = Constants.collectionViewContentInsets.vertical + CGFloat(Constants.numberOfRows - 1) * Constants.interItemSpace
        let side = (view.bounds.height - emptySpace) / CGFloat(Constants.numberOfRows)
        cellSize = CGSize(width: side, height: side)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.registerCells(withCollectionView: collectionView)
        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard
            let sticker = dataSource.asset(atIndex: (indexPath as NSIndexPath).item),
            let remoteID = sticker.remoteID ,
            dataSource.trayState == .populated
        else {
            if let _ = collectionView.cellForItem(at: indexPath) as? TrayRetryLoadCollectionViewCell {
                dataSource.fetchStickers()
            }
            else {
                Log.debug("Selected asset from an unexpected index in Tray")
            }
            return
        }
        guard StickerSearchResultPreviewCellPopulator.currentUserCanAccess(sticker) else {
            let originViewController = parent ?? self
            let router = Router(originViewController: originViewController, dependencyManager: dependencyManager)
            router.navigate(to: DeeplinkDestination.vipSubscription, from: DeeplinkContext(value: DeeplinkContext.mainFeed))
            return
        }
        
        progressHUD = showExportingHUD(delegate: self)
        mediaExporter?.cancelDownload()
        mediaExporter = nil
        let exporter = exportMedia(fromSearchResult: sticker) { [weak self] state in
            switch state {
                case .success(let result):
                    self?.progressHUD?.hide(animated: true)
                    let localAssetParameters = ContentMediaAsset.LocalAssetParameters(contentType: .sticker, remoteID: remoteID, source: nil, size: sticker.assetSize, url: sticker.sourceMediaURL as NSURL?)
                    
                    guard
                        let strongSelf = self,
                        let asset = ContentMediaAsset(initializationParameters: localAssetParameters),
                        let previewImage = result.exportPreviewImage
                    else {
                        return
                    }
                    strongSelf.delegate?.tray(strongSelf, selectedAsset: asset, withPreviewImage: previewImage)
                case .failure(let error):
                    self?.progressHUD?.hide(animated: true)
                    self?.showHUD(forRenderingError: error)
                case .canceled:()
            }
        }
        mediaExporter = exporter
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard
            let _ = dataSource.asset(atIndex: indexPath.row) ,
            dataSource.trayState == .populated
        else {
            return view.bounds.insetBy(Constants.collectionViewContentInsets).size
        }
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.collectionViewContentInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
    
    // MARK: - LoadingCancellableViewDelegate
    
    func cancel() {
        progressHUD?.hide(animated: true)
        mediaExporter?.cancelDownload()
    }
}
