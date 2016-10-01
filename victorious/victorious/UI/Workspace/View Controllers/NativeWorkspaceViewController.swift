//
//  NativeWorkspaceViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A view controller that simply contains a UIVideoEditorController and
/// handles the delegate methods from it appropriately
class NativeWorkspaceViewController: VWorkspaceViewController, UIVideoEditorControllerDelegate, UINavigationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    // Since we're not using initialization from VBaseWorkspaceViewController
    // and dependencyManager is read-only, we need to manage our own dependencyManager
    // by backing it with this internal var.
    fileprivate var internalDependencyManager: VDependencyManager!
    
    override var dependencyManager: VDependencyManager! {
        return internalDependencyManager
    }
    
    let animator = PushTransitionAnimator()
    
    fileprivate static let videoMaximumDuration: TimeInterval = 600
    
    override var supportsTools: Bool {
        return false
    }
    
    override static func new(with dependencyManager: VDependencyManager) -> NativeWorkspaceViewController {
        let nativeWorkspace: NativeWorkspaceViewController = v_initialViewControllerFromStoryboard()
        nativeWorkspace.transitioningDelegate = nativeWorkspace
        nativeWorkspace.internalDependencyManager = dependencyManager
        return nativeWorkspace
    }
    
    fileprivate var videoEditorViewController: UIVideoEditorController! {
        didSet {
            videoEditorViewController.videoQuality = .typeHigh
            videoEditorViewController.videoMaximumDuration = NativeWorkspaceViewController.videoMaximumDuration
            
            let path = mediaURL.path
            
            if !UIVideoEditorController.canEditVideo(atPath: path) {
                assertionFailure("Handling a MediaURL that the video editor controller can't handle")
                v_showDefaultErrorAlert() { _ in
                    self.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                return
            }
            videoEditorViewController.videoPath = path
            videoEditorViewController.delegate = self
            let navigationBar = videoEditorViewController.navigationBar
            dependencyManager.applyStyle(to: navigationBar)
            // Reset the background image of the navigation bar so that it matches the
            // trimmer view that the editor places right below it
            navigationBar.setBackgroundImage(nil, for: .default)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videoEditorViewController = childViewControllers.first as? UIVideoEditorController else {
            fatalError("Did not find a video editor controller as a child view controller in NativeWorkspaceViewController")
        }
        self.videoEditorViewController = videoEditorViewController
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = true
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false
        return animator
    }

    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let navigationItem = viewController.navigationItem
        guard let oldLeftBarButton = navigationItem.leftBarButtonItem else {
            assertionFailure("UIVideoEditorViewController changed how it's cancel button works! It will be shown with the default cancel text instead.")
            return
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: oldLeftBarButton.target, action: oldLeftBarButton.action)
    }
    
    // MARK: - UIVideoEditorControllerDelegate
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        v_showErrorDefaultError()
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        let editedMediaURL = URL(fileURLWithPath: editedVideoPath)
        
        guard let previewImage = editedMediaURL.v_videoPreviewImage else {
            v_showErrorDefaultError()
            return
        }
        
        animator.dismissing = true
        
        presentingViewController?.dismiss(animated: true) {
            self.callCompletion(withSuccess: true, previewImage: previewImage, renderedMediaURL: editedMediaURL)
        }
    }
}
