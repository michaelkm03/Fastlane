//
//  VPurchaseSettingsViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 5/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import MBProgressHUD
import VictoriousIOSSDK

extension VPurchaseSettingsViewController {
    
    func setIsLoading(_ isLoading: Bool, title: String? = nil) {
        if isLoading {
            MBProgressHUD.hide(for: self.view, animated: false)
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHUD.mode = .indeterminate
            progressHUD.label.text = title
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func queueValidateSubscriptionOperationWithURL(_ url: NSURL?, shouldForceSuccess: Bool, completion: @escaping () -> Void) {
        guard let templatePath = url?.absoluteString else {
            completion()
            return
        }
        
        VIPValidateSubscriptionOperation(apiPath: APIPath(templatePath: templatePath), shouldForceSuccess: shouldForceSuccess)?.queue { _ in
            completion()
        }
    }
    
    func queueClearSubscriptionOperationWithCompletion(_ completion: @escaping () -> Void) {
        VIPClearSubscriptionOperation().queue { _ in
            completion()
        }
    }
}
