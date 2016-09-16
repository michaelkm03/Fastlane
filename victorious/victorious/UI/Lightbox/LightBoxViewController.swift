//
//  LightBoxViewController.swift
//  victorious
//
//  Created by Tian Lan on 9/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A lightbox to display media full screen, with black background.
/// - note: Initialize an instance and present it. Currently, lightbox only supports landscape mode. When rotating back to portrait, it'll dismiss it self.
class LightBoxViewController: UIViewController {
    
    // MARK: - Dismissal blocks
    
    var afterDismissal: () -> Void = { }
    var beforeDismissal: () -> Void = { }
    
    // MARK: - Initialization
    
    let mediaContentView: MediaContentView
    
    init(mediaContentView: MediaContentView) {
        self.mediaContentView = mediaContentView
        mediaContentView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mediaContentView)
        view.v_addFitToParentConstraintsToSubview(mediaContentView)
        view.backgroundColor = .blackColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(orientationChanged), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        mediaContentView.didPresent()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .All
    }
    
    // MARK: - Notification response
    
    private dynamic func orientationChanged() {
        guard UIDevice.currentDevice().orientation == .Portrait else {
            return
        }
        
        beforeDismissal()
        dismissViewControllerAnimated(true) {
            self.afterDismissal()
        }
    }
}
