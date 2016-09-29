//
//  LibraryCreationFlowController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Displays a flow starting with a library from which the user can select either a photo or a video
class LibraryCreationFlowController: VAbstractImageVideoCreationFlowController, MixedMediaCreationFlow {
    
    fileprivate struct Constants {
        static let imageVideoLibraryKey = "imageVideoLibrary"
    }
    
    override func mediaType() -> MediaType {

        guard let capturedMediaURL = capturedMediaURL else {
            return .unknown
        }
        
        return (capturedMediaURL as NSURL).v_hasVideoExtension() ? .video : .image
    }
    
    override func gridViewController(withDependencyManager dependencyManager: VDependencyManager) -> VAssetCollectionGridViewController? {
        return dependencyManager.templateValue(ofType: VAssetCollectionGridViewController.self, forKey: Constants.imageVideoLibraryKey, withAddedDependencies:[VAssetCollectionGridViewControllerMediaType : NSNumber(integer: PHAssetMediaType.unknown.rawValue)]) as? VAssetCollectionGridViewController
    }
    
    override func workspaceViewController(withDependencyManager dependencyManager: VDependencyManager) -> VWorkspaceViewController? {
        let workspace: VWorkspaceViewController? = VCreationFlowPresenter.preferredWorkspaceForMediaType(mediaType(), fromDependencyManager: dependencyManager)
        
        guard let selectedWorkspace = workspace else {
            fatalError("Workspace requested from mixed media creation flow controller when no valid media was selected")
        }
        
        return selectedWorkspace
    }
    
    override func configurePublishParameters(_ publishParameters: VPublishParameters, withWorkspace workspace: VWorkspaceViewController) {
        
        updatePublishParameters(publishParameters, workspace: workspace)
    }
    
    override func downloaderWithAsset(_ asset: PHAsset) -> VAssetDownloader? {
        if asset.mediaType == .Image {
            return VImageAssetDownloader(asset: asset)
        } else if asset.mediaType == .Video {
            return VVideoAssetDownloader(asset: asset)
        }
        assertionFailure("Library creation view controller was asked for an asset downloader with for an unsupported asset type")
        return nil
    }
    
    override func alternateCaptureOptions() -> [VAlternateCaptureOption] {
        return []
    }
    
    override func shouldSkipTrimmerForVideoLength() -> Bool {
        return false
    }
    
    // MARK: VAssetCollectionGridViewControllerDelegate
    
    override func gridViewController(_ gridViewController: VAssetCollectionGridViewController, selectedAsset asset: PHAsset) {
        source = .Library
        super.gridViewController(gridViewController, selectedAsset: asset)
    }
}
