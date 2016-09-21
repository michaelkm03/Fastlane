//
//  Tray.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import MBProgressHUD

// Conformers describe a
protocol Tray: TrayDataSourceDelegate {
    weak var delegate: TrayDelegate? { get set }
}

enum TrayMediaCompletionState {
    case success(MediaSearchResult)
    case failure(NSError?)
    case canceled
}

extension Tray where Self: UIViewController {
    func showHUD(forRenderingError error: NSError?) {
        if error?.code != NSURLErrorCancelled {
            MBProgressHUD.hideAllHUDsForView(view, animated: false)
            let errorTitle = NSLocalizedString("Error rendering media", comment: "")
            v_showErrorWithTitle(errorTitle, message: "")
        }
    }
    
    func showExportingHUD(delegate delegate: LoadingCancellableViewDelegate) -> MBProgressHUD {
        guard let view = NSBundle.mainBundle().loadNibNamed("LoadingCancellableView", owner: self, options: nil).first as? LoadingCancellableView else {
            fatalError()
        }
        view.delegate = delegate
        
        MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
        let progressHUD = MBProgressHUD.showHUDAddedTo( self.view.window, animated: true )
        progressHUD.mode = MBProgressHUDMode.CustomView
        progressHUD.customView = view
        progressHUD.square = true;
        progressHUD.dimBackground = true
        progressHUD.show(true)
        return progressHUD
    }
}

// Conformers receive messages when an asset is selected from a tray
protocol TrayDelegate: class {
    func tray(tray: Tray, selectedAsset asset: ContentMediaAsset, withPreviewImage previewImage: UIImage)
}
