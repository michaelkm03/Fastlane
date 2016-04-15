//
//  SelectMediaAttachmentOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 4/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class SelectMediaAttachmentOperation: BackgroundOperation, MediaSearchDelegate {
    
    struct Result {
        let previewImage: UIImage
        let mediaAttachment: MediaAttachment
    }
    
    /// The output of this operation, to be read by calling code when complete
    var result: Result?
    
    private weak var originViewController: UIViewController?
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private let attachmentType: MediaAttachmentType
    
    required init( originViewController: UIViewController,
                   dependencyManager: VDependencyManager,
                   attachmentType: MediaAttachmentType,
                   animated: Bool = true) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.attachmentType = attachmentType
        self.animated = animated
    }

    override func start() {
        beganExecuting()
        dispatch_async(dispatch_get_main_queue()) {
            self.performNavigation()
        }
    }
    
    private func performNavigation() {
        
        let dataSource: MediaSearchDataSource
        switch attachmentType {
        case .GIF:
            dataSource = GIFSearchDataSource()
        case .Image:
            dataSource = ImageSearchDataSource(defaultSearchTerm: "")
        default:
            fatalError("Not supported")
        }
        
        // We are sending only URLs and size data for this attachment,
        // no need to render media to disk to send byte stream to backend.
        dataSource.options.shouldSkipExportRendering = true
        
        let mediaSearchViewController = MediaSearchViewController.mediaSearchViewController(
            dataSource: dataSource,
            dependencyManager: dependencyManager
        )
        mediaSearchViewController.delegate = self
        
        guard let originViewController = originViewController?.navigationController ?? originViewController else {
            cancel()
            finishedExecuting()
            return
        }
        
        let navigationController = UINavigationController(rootViewController: mediaSearchViewController)
        originViewController.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - MediaSearchDelegate
    
    func mediaSearchDidCancel() {
        cancel()
        finishedExecuting()
        originViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaSearchResultSelected(selectedMediaSearchResult: MediaSearchResult) {
        guard let mediaURL = selectedMediaSearchResult.sourceMediaURL,
            let thumbnailURL = selectedMediaSearchResult.thumbnailImageURL,
            let previewImage = selectedMediaSearchResult.exportPreviewImage else {
                cancel()
                finishedExecuting()
                return
        }
        
        let selectedMediaAttachment = MediaAttachment(
            url: mediaURL,
            type: attachmentType,
            thumbnailURL: thumbnailURL,
            size: selectedMediaSearchResult.assetSize
        )
        result = Result(
            previewImage: previewImage,
            mediaAttachment: selectedMediaAttachment
        )
        
        finishedExecuting()
        originViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
