//
//  Tray.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import MBProgressHUD

/// Conformers describe a object that allows for the selection of a piece of media
protocol Tray: TrayDataSourceDelegate {
    weak var delegate: TrayDelegate? { get set }
}

/// Encapsulates the result of media exporting functions within trays
enum TrayMediaCompletionState {
    case success(MediaSearchResult)
    case failure(NSError?)
    case canceled
}

extension Tray where Self: UIViewController {
    func showHUD(forRenderingError error: NSError?) {
        if error?.code != NSURLErrorCancelled, let window = view.window {
            MBProgressHUD.hideAllHUDsForView(view, animated: false)
            let errorTitle = NSLocalizedString("Error rendering media", comment: "")
            v_showErrorWithTitle(errorTitle, message: "", onView: window)
        }
    }
    
    func showExportingHUD(delegate delegate: LoadingCancellableViewDelegate) -> MBProgressHUD {
        guard
            let cancelableView = NSBundle.mainBundle().loadNibNamed("LoadingCancellableView", owner: self, options: nil).first as? LoadingCancellableView,
            let window = self.view.window
        else {
            fatalError()
        }
        cancelableView.delegate = delegate
        
        MBProgressHUD.hideAllHUDsForView(window, animated: false)
        let progressHUD = MBProgressHUD.showHUDAddedTo(window, animated: true)
        progressHUD.mode = MBProgressHUDMode.CustomView
        progressHUD.customView = cancelableView
        progressHUD.square = true;
        progressHUD.dimBackground = true
        progressHUD.show(true)
        return progressHUD
    }
}

/// Conformers receive messages when an asset is selected from a tray
protocol TrayDelegate: class {
    func tray(tray: Tray, selectedAsset asset: ContentMediaAsset, withPreviewImage previewImage: UIImage)
}
