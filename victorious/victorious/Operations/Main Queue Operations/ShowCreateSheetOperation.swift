//
//  ShowCreateSheetOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

@objc class ShowCreateSheetOperation: MainQueueOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    
    var chosenCreationType: VCreationType = .Unknown
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager ) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        guard !self.cancelled && !VAutomation.shouldAlwaysShowLoginScreen() else {
            self.finishedExecuting()
            return
        }
        
        if let createSheet = self.dependencyManager.templateValueOfType( VCreateSheetViewController.self, forKey:"createSheet" ) as? VCreateSheetViewController {
            
            createSheet.completionHandler = { (createSheetViewController, chosenCreationType) in
                self.chosenCreationType = chosenCreationType
                self.finishedExecuting()
            }
            self.originViewController.presentViewController(createSheet, animated: true, completion: nil)
        }
        else {
            self.originViewController.v_showErrorWithTitle(nil, message: NSLocalizedString( "GenericFailMessage", comment:"" ))
            self.finishedExecuting()
        }
    }
}
