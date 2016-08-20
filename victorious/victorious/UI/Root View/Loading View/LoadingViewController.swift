//
//  LoadingViewController.swift
//  victorious
//
//  Created by Tian Lan on 8/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import MBProgressHUD

extension VLoadingViewController {
    func startLoading() {
        guard !isLoading else {
            return
        }
        isLoading = true
        
        let loadingOperation = StartLoadingOperation()
        loadingOperation.queue { [weak self] result in
            self?.isLoading = false
            self?.progressHUD.taskInProgress = false
            self?.progressHUD.hide(true)
            guard let template = loadingOperation.template else {
                return
            }
            self?.onDoneLoadingWithTemplateConfiguration(template as [NSObject: AnyObject])
        }
        
        progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHUD.mode = .Indeterminate
        progressHUD.graceTime = 2.0
        progressHUD.taskInProgress = true
    }
}
