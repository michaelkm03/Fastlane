//
//  IMAAdViewController.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@objc class IMAAdViewController: VAdViewController {
    let adManager: IMAAdManager
    let adTag: String

    init(player: AVPlayer, adTag: String, nibName: String? = nil, nibBundle: NSBundle? = nil) {
        self.adTag = adTag
        adManager = IMAAdManager(player: player)
        super.init(nibName: nibName, bundle: nibBundle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func startAdManager() {
        adManager.requestAds(adTag: adTag, adContainerView: playerView)
    }
}
