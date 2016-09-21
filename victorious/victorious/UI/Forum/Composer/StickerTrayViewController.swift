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
    var cellSize: CGSize = .zero {
        didSet {
            self.dataSource.cellSize = cellSize
            self.collectionView.reloadData()
        }
    }
    
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
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard
            let sticker = dataSource.asset(atIndex: indexPath.item) where
            dataSource.trayState == .Populated
        else {
            if let _ = collectionView.cellForItemAtIndexPath(indexPath) as? TrayRetryLoadCollectionViewCell {
                dataSource.fetchStickers()
            }
            else {
                Log.debug("Selected asset from an unexpected index in Tray")
            }
            return
        }
        
        let imageAssets = sticker.assets.filter { return $0.url?.v_hasImageExtension() ?? false }
        let largestAsset: ContentMediaAssetModel? = imageAssets.reduce(nil) { (largestAsset, newAsset) -> ContentMediaAssetModel? in
            //TODO: Cleanup
            if largestAsset == nil || (newAsset.size?.area > largestAsset?.size?.area && newAsset.url != nil) {
                return newAsset
            }
            return largestAsset
        }
        
        guard
            let stickerAsset = largestAsset as? ContentMediaAsset,
            let imageURL = stickerAsset.url
        else {
            return
        }
        
        showExportingHUD()
        do {
            let previewImageData = try NSData(contentsOfURL: imageURL, options: [])
            self.dismissHUD()
            guard let image = UIImage(data: previewImageData) else {
                return
            }
            delegate?.tray(self, selectedAsset: stickerAsset, withPreviewImage: image)
        } catch let error as NSError {
            showHUD(renderingError: error)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        guard let _ = dataSource.asset(atIndex: indexPath.row) where
            dataSource.trayState == .Populated else {
                return view.bounds.insetBy(Constants.collectionViewContentInsets).size
        }
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return Constants.collectionViewContentInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return Constants.interItemSpace
    }
}
