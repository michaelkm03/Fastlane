//
//  Tray.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import MBProgressHUD
import VictoriousIOSSDK

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
            MBProgressHUD.hideAllHUDs(for: view, animated: false)
            let errorTitle = NSLocalizedString("Error rendering media", comment: "")
            v_showErrorWithTitle(errorTitle, message: "", onView: window)
        }
    }
    
    func showExportingHUD(delegate: LoadingCancellableViewDelegate) -> MBProgressHUD? {
        guard
            let cancelableView = Bundle.main.loadNibNamed("LoadingCancellableView", owner: self, options: nil)?.first as? LoadingCancellableView,
            let window = self.view.window
        else {
            assertionFailure("Failed to show exporting HUD")
            return nil
        }
        cancelableView.delegate = delegate
        
        MBProgressHUD.hideAllHUDs(for: window, animated: false)
        let progressHUD = MBProgressHUD.showAdded(to: window, animated: true)
        progressHUD?.mode = MBProgressHUDMode.customView
        progressHUD?.customView = cancelableView
        progressHUD?.isSquare = true;
        progressHUD?.dimBackground = true
        progressHUD?.show(true)
        return progressHUD
    }
}

/// Conformers receive messages when an asset is selected from a tray
protocol TrayDelegate: class {
    func tray(_ tray: Tray, selectedAsset asset: ContentMediaAsset, withPreviewImage previewImage: UIImage)
}
