//
//  LightBoxViewController.swift
//  victorious
//
//  Created by Tian Lan on 9/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class LightBoxViewController: UIViewController {
    let mediaContentView: MediaContentView
    var afterDismissal: () -> Void = { }
    
    init(mediaContentView: MediaContentView) {
        self.mediaContentView = mediaContentView
        mediaContentView.translatesAutoresizingMaskIntoConstraints = false
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .All
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mediaContentView)
        view.v_addFitToParentConstraintsToSubview(mediaContentView)
        
        view.backgroundColor = .blackColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        mediaContentView.didPresent()
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if toInterfaceOrientation == .Portrait {
            dismissViewControllerAnimated(true) {
                self.afterDismissal()
            }
        }
    }
}
