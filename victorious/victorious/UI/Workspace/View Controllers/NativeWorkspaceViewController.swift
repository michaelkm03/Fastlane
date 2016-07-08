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
    private var internalDependencyManager: VDependencyManager!
    
    override var dependencyManager: VDependencyManager! {
        return internalDependencyManager
    }
    
    let animator = PushTransitionAnimator()
    
    private static let videoMaximumDuration: NSTimeInterval = 600
    
    override var supportsTools: Bool {
        return false
    }
    
    override static func newWithDependencyManager(dependencyManager: VDependencyManager) -> NativeWorkspaceViewController {
        let nativeWorkspace: NativeWorkspaceViewController = v_initialViewControllerFromStoryboard()
        nativeWorkspace.transitioningDelegate = nativeWorkspace
        nativeWorkspace.internalDependencyManager = dependencyManager
        return nativeWorkspace
    }
    
    private var videoEditorViewController: UIVideoEditorController! {
        didSet {
            videoEditorViewController.videoQuality = .TypeHigh
            videoEditorViewController.videoMaximumDuration = NativeWorkspaceViewController.videoMaximumDuration
            guard let path = mediaURL.path else {
                assertionFailure("Somehow recieved a media url with no path in NativeWorkspaceViewController")
                v_showDefaultErrorAlert() { _ in
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
                return
            }
            if !UIVideoEditorController.canEditVideoAtPath(path) {
                assertionFailure("Handling a MediaURL that the video editor controller can't handle")
                v_showDefaultErrorAlert() { _ in
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
                return
            }
            videoEditorViewController.videoPath = path
            videoEditorViewController.delegate = self
            let navigationBar = videoEditorViewController.navigationBar
            dependencyManager.applyStyleToNavigationBar(navigationBar)
            // Reset the background image of the navigation bar so that it matches the
            // trimmer view that the editor places right below it
            navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let videoEditorViewController = childViewControllers.first as? UIVideoEditorController else {
            fatalError("Did not find a video editor controller as a child view controller in NativeWorkspaceViewController")
        }
        self.videoEditorViewController = videoEditorViewController
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = true
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false
        return animator
    }

    // MARK: - UINavigationControllerDelegate

    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        let navigationItem = viewController.navigationItem
        guard let oldLeftBarButton = navigationItem.leftBarButtonItem else {
            assertionFailure("UIVideoEditorViewController changed how it's cancel button works! It will be shown with the default cancel text instead.")
            return
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .Plain, target: oldLeftBarButton.target, action: oldLeftBarButton.action)
    }
    
    // MARK: - UIVideoEditorControllerDelegate
    
    func videoEditorControllerDidCancel(editor: UIVideoEditorController) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func videoEditorController(editor: UIVideoEditorController, didFailWithError error: NSError) {
        v_showErrorDefaultError()
    }
    
    func videoEditorController(editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        
        let editedMediaURL = NSURL(fileURLWithPath: editedVideoPath)
        guard let previewImage = editedMediaURL.v_videoPreviewImage else {
            v_showErrorDefaultError()
            return
        }
        animator.dismissing = true
        presentingViewController?.dismissViewControllerAnimated(true) {
            self.callCompletionWithSuccess(true, previewImage: previewImage, renderedMediaURL: editedMediaURL)
        }
    }
}
