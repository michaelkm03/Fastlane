//
//  ShowMediaLightboxOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowMediaLightboxOperation: NavigationOperation {
    
    let originViewController: UIViewController
    let image: UIImage?
    let videoURL: NSURL?
    let referenceView: UIView
    
    private let transitioningDelegate: VLightboxTransitioningDelegate
    
    init(originViewController: UIViewController, preloadedImage: UIImage, referenceView: UIView) {
        self.originViewController = originViewController
        self.referenceView = referenceView
        self.videoURL = nil
        self.image = preloadedImage
        self.transitioningDelegate = VLightboxTransitioningDelegate(referenceView: referenceView)
    }
    
    init(originViewController: UIViewController, previewImage: UIImage, videoURL: NSURL, referenceView: UIView) {
        self.originViewController = originViewController
        self.referenceView = referenceView
        self.videoURL = videoURL
        self.image = nil
        self.transitioningDelegate = VLightboxTransitioningDelegate(referenceView: referenceView)
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
        var lightboxController: VLightboxViewController
        if let videoURL = videoURL {
            lightboxController = VVideoLightboxViewController(previewImage: image, videoURL: videoURL)
        } else {
            lightboxController = VImageLightboxViewController(image: image)
        }
        lightboxController.onCloseButtonTapped = {
            self.originViewController.dismissViewControllerAnimated(true, completion: nil)
        }
        lightboxController.transitioningDelegate = transitioningDelegate
        lightboxController.modalPresentationStyle = .FullScreen
        originViewController.presentViewController(lightboxController, animated: true) {
            self.finishedExecuting()
        }
    }
}
