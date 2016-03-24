//
//  LibraryCreationFlowController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class LibraryCreationFlowController: VAbstractImageVideoCreationFlowController {
    
    private struct Constants {
        static let imageVideoLibraryKey = "imageVideoLibrary"
    }
        
    private var currentVideoLength: NSTimeInterval?
    
    override func mediaType() -> MediaType {

        guard let capturedMediaURL = capturedMediaURL else {
            return .Unknown
        }
        
        return capturedMediaURL.v_hasVideoExtension() ? .Video : .Image
    }
    
    override func gridViewControllerWithDependencyManager(dependencyManager: VDependencyManager!) -> VAssetCollectionGridViewController! {
        
        return dependencyManager.templateValueOfType(VAssetCollectionGridViewController.self, forKey: Constants.imageVideoLibraryKey, withAddedDependencies:[VAssetCollectionGridViewControllerMediaType : NSNumber(integer: PHAssetMediaType.Unknown.rawValue)]) as! VAssetCollectionGridViewController
    }
    
    override func workspaceViewControllerWithDependencyManager(dependencyManager: VDependencyManager!) -> VWorkspaceViewController! {
        
        let selectedMediaType = mediaType()
        switch selectedMediaType {
        case .Video:
            return dependencyManager.viewControllerForKey(VDependencyManagerVideoWorkspaceKey) as! VWorkspaceViewController
        case .Image:
            return dependencyManager.viewControllerForKey(VDependencyManagerImageWorkspaceKey) as! VWorkspaceViewController
        default:
            fatalError("Workspace requested from library creation flow controller when no valid media was selected")
        }
    }
    
    override func configurePublishParameters(publishParameters: VPublishParameters!, withWorkspace workspace: VWorkspaceViewController!) {
        
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
    
    override func downloaderWithAsset(asset: PHAsset!) -> VAssetDownloader! {
        if asset.mediaType == .Image {
            return VImageAssetDownloader(asset: asset)
        } else if asset.mediaType == .Video {
            return VVideoAssetDownloader(asset: asset)
        }
        fatalError("Library creation view controller was asked for an asset downloader with for an unsupported asset type")
    }
    
    override func alternateCaptureOptions() -> [VAlternateCaptureOption]! {
        return []
    }
    
    override func shouldSkipTrimmerForVideoLength() -> Bool {
        return false
    }
    
    // MARK: VAssetCollectionGridViewControllerDelegate
    
    override func gridViewController(gridViewController: VAssetCollectionGridViewController!, selectedAsset asset: PHAsset!) {
        super.gridViewController(gridViewController, selectedAsset: asset)
        if asset.mediaType == .Video {
            currentVideoLength = asset.duration
        }
    }
}
