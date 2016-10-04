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
    
    var didDismiss: () -> Void = { }
    var willDismiss: () -> Void = { }
    
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
        view.v_addFitToParentConstraints(toSubview: mediaContentView)
        view.backgroundColor = .black
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mediaContentView.didPresent()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .all
    }
    
    // MARK: - Notification response
    
    fileprivate dynamic func orientationChanged() {
        guard UIDevice.current.orientation == .portrait else {
            return
        }
        
        willDismiss()
        dismiss(animated: true) {
            self.didDismiss()
        }
    }
}
