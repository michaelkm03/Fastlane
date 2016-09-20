//
//  Tray.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import MBProgressHUD

protocol Tray: TrayDataSourceDelegate, LoadingCancellableViewDelegate {
    weak var delegate: TrayDelegate? { get set }
    
    var mediaExporter: MediaSearchExporter? { get set }
    var progressHUD: MBProgressHUD? { get set }
}

enum TrayMediaCompletionState {
    case success(MediaSearchResult)
    case failure(NSError?)
    case canceled
}

extension Tray {
    func exportMedia(fromSearchResult mediaSearchResultObject: MediaSearchResult, completionBlock: (TrayMediaCompletionState) -> ()) {
        self.mediaExporter?.cancelDownload()
        self.mediaExporter = nil
        
        let mediaExporter = MediaSearchExporter(mediaSearchResult: mediaSearchResultObject)
        mediaExporter.loadMedia() { (previewImage, mediaURL, error) in
            dispatch_after(0.5) {
                if mediaExporter.cancelled {
                    completionBlock(.canceled)
                } else if
                    let previewImage = previewImage,
                    let mediaURL = mediaURL {
                    mediaSearchResultObject.exportPreviewImage = previewImage
                    mediaSearchResultObject.exportMediaURL = mediaURL
                    completionBlock(.success(mediaSearchResultObject))
                } else if let error = error {
                    completionBlock(.failure(error))
                } else {
                    Log.warning("Encountered unexpected media output state in tray")
                }
            }
        }
        self.mediaExporter = mediaExporter
    }
}

extension Tray where Self: UIViewController {
    func showHUD(renderingError error: NSError?) {
        if error?.code != NSURLErrorCancelled {
            MBProgressHUD.hideAllHUDsForView(view, animated: false)
            let errorTitle = NSLocalizedString("Error rendering media", comment: "")
            v_showErrorWithTitle(errorTitle, message: "")
        }
    }
    
    func showExportingHUD() {
        guard let view = NSBundle.mainBundle().loadNibNamed("LoadingCancellableView", owner: self, options: nil).first as? LoadingCancellableView else {
            return
        }
        view.delegate = self
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
        progressHUD = MBProgressHUD.showHUDAddedTo( self.view.window, animated: true )
        progressHUD?.mode = MBProgressHUDMode.CustomView
        progressHUD?.customView = view
        progressHUD?.square = true;
        progressHUD?.dimBackground = true
        progressHUD?.show(true)
    }
    
    func dismissHUD() {
        progressHUD?.hide(true)
    }
    
    func cancel() {
        dismissHUD()
        mediaExporter?.cancelDownload()
    }
}

protocol TrayDelegate: class {
    func tray(tray: Tray, selectedAsset asset: ContentMediaAsset, withPreviewImage previewImage: UIImage)
}
