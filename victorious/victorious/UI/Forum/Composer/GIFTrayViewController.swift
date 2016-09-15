//
//  GIFTrayViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class GIFTrayViewController: UIViewController, Tray, UICollectionViewDelegate {
    weak var delegate: TrayDelegate?
    
    lazy var dataSource: GIFTrayDataSource = {
        //TODO: Make gif tray data source take in dependency manager or endpoints
        return GIFTrayDataSource()
    }()
    
    @IBOutlet private var collectionView: UICollectionView!
    
    private var dependencyManager: VDependencyManager!
    
    static func new(dependencyManager: VDependencyManager) -> GIFTrayViewController {
        let tray = GIFTrayViewController.v_initialViewControllerFromStoryboard() as GIFTrayViewController
        tray.dependencyManager = dependencyManager
        return tray
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = dataSource
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //TODO: Get preview image and url from asset
    }
}
