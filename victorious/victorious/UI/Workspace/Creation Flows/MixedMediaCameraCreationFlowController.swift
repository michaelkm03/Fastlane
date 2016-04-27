//
//  MixedMediaCameraCreationFlowController.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Displays a flow starting with a camera that can take either a photo or a video
class MixedMediaCameraCreationFlowController: VAbstractImageVideoCreationFlowController, MixedMediaCameraViewControllerDelegate {
    
    private struct Constants {
        static let mixedMediaCameraKey = "mixedMediaCameraScreen"
    }
    
    private lazy var mixedMediaCameraViewController: MixedMediaCameraViewController = {
        let mixedMediaCamera = MixedMediaCameraViewController.mixedMediaCamera(self.dependencyManager, cameraContext: .MixedMediaContentCreation)
        mixedMediaCamera.delegate = self
        return mixedMediaCamera
    }()
        
    override func mediaType() -> MediaType {
        
        guard let capturedMediaURL = capturedMediaURL else {
            return .Unknown
        }
        
        return capturedMediaURL.v_hasVideoExtension() ? .Video : .Image
    }
    
    override func gridViewControllerWithDependencyManager(dependencyManager: VDependencyManager) -> VAssetCollectionGridViewController? {
        return nil
    }
    
    override func workspaceViewControllerWithDependencyManager(dependencyManager: VDependencyManager) -> VWorkspaceViewController? {
        
        return VCreationFlowPresenter.preferredWorkspaceForMediaType(mediaType(), fromDependencyManager: dependencyManager)
    }
    
    override func configurePublishParameters(publishParameters: VPublishParameters, withWorkspace workspace: VWorkspaceViewController) {
        
        if let videoToolController = workspace.toolController as? VVideoToolController {
            publishParameters.didTrim = videoToolController.didTrim
            publishParameters.isGIF = false
            publishParameters.isVideo = true
        } else if let imageToolController = workspace.toolController as? VImageToolController {
            publishParameters.embeddedText = imageToolController.embeddedText
            publishParameters.textToolType = imageToolController.textToolType
            publishParameters.filterName = imageToolController.filterName
            publishParameters.didCrop = imageToolController.didCrop
            publishParameters.isVideo = false
        } else {
            fatalError("Library creation flow controller encountered an unexpected tool controller")
        }
    }
    
    override func downloaderWithAsset(asset: PHAsset) -> VAssetDownloader? {
        if asset.mediaType == .Image {
            return VImageAssetDownloader(asset: asset)
        } else if asset.mediaType == .Video {
            return VVideoAssetDownloader(asset: asset)
        }
        return nil
    }
    
    override func alternateCaptureOptions() -> [VAlternateCaptureOption] {
        return []
    }
    
    override func shouldSkipTrimmerForVideoLength() -> Bool {
        return false
    }
    
    override func initialViewController() -> UIViewController {
        return mixedMediaCameraViewController
    }
    
    func mixedMediaCameraViewController(mixedMediaCameraViewController: MixedMediaCameraViewController, capturedImageWithMediaURL mediaURL: NSURL, previewImage: UIImage) {
        source = .Camera
        self.captureFinishedWithMediaURL(mediaURL, previewImage: previewImage)
    }
}
