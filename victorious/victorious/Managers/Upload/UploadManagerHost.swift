//
//  UploadManagerHost.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Describes a type that can host the UI for showing media upload progress.
@objc(VUploadManagerHost)
protocol UploadManagerHost: VUploadProgressViewControllerDelegate {
    var uploadProgressViewController: VUploadProgressViewController? { get set }
    
    func addUploadManagerToViewController(_ viewController: UIViewController, topInset: CGFloat)
}

/// Intended to be utilized by types conforming to `UploadManagerHost` when
/// `addUploadManagerToViewController` is called on them.
@objc(VUploadManagerHelper)
class UploadManagerHelper: NSObject {
    static func addUploadManagerToViewController(_ viewController: UIViewController, topInset: CGFloat) {
        guard
            let managerHost = viewController as? UploadManagerHost,
            managerHost.uploadProgressViewController == nil
        else {
            return
        }
        
        guard let uploadProgressViewController = VUploadProgressViewController(for: VUploadManager.shared()) else {
            return
        }
        
        if let existingParent = uploadProgressViewController.parent {
            if existingParent === viewController {
                return
            }
            
            removeUploadViewController(uploadProgressViewController, fromExistingParent: existingParent)
        }
        
        uploadProgressViewController.delegate = managerHost
        addUploadViewController(uploadProgressViewController, toViewController: viewController, withTopInset: Float(topInset))
        managerHost.uploadProgressViewController = uploadProgressViewController
    }
    
    private static func removeUploadViewController(_ uploadViewController: VUploadProgressViewController, fromExistingParent existingParent: UIViewController) {
        if let parent = existingParent as? UploadManagerHost {
            parent.uploadProgressViewController = nil
        }
        
        uploadViewController.willMove(toParentViewController: nil)
        uploadViewController.view.removeFromSuperview()
        uploadViewController.removeFromParentViewController()
    }

    private static func addUploadViewController(_ uploadViewController: VUploadProgressViewController, toViewController viewController: UIViewController, withTopInset topInset: Float) {
        viewController.addChildViewController(uploadViewController)
        let progressVCView = uploadViewController.view
        progressVCView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(progressVCView)
        uploadViewController.didMove(toParentViewController: viewController)
        progressVCView.hidden = true
        viewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressVCView]|", options: [], metrics: nil, views: ["progressVCView" : progressVCView]))
        viewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-topInset-[progressVCView(44)]", options: [], metrics: ["topInset" : NSNumber(float: topInset)], views: ["progressVCView" : progressVCView]))
    }
}
