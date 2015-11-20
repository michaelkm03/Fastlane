//
//  ShowCreateSheetOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

@objc class ShowCreateSheetOperation: Operation {
    
    private let showCreationSheetFromTop: Bool
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    
    var chosenCreationType: VCreationType = .Unknown
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, showCreationSheetFromTop: Bool = false ) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.showCreationSheetFromTop = showCreationSheetFromTop
        
        // TODO: This is here to show login view contorller before this operation can occur
        super.init()
        
        if VUser.currentUser() == nil {
            let loginOperation = ShowLoginOperation(
                originViewController: originViewController,
                dependencyManager: dependencyManager,
                context: .CreatePost
            )
            loginOperation.queueBefore( self, queue: Operation.defaultQueue )
        }
    }
    
    override func start() {
        super.start()
        
        dispatch_async( dispatch_get_main_queue() ) {
            guard !self.cancelled && !VAutomation.shouldAlwaysShowLoginScreen() else {
                self.finishedExecuting()
                return
            }
            
            let addedDependencies = [ "animateFromTop" : self.showCreationSheetFromTop ]
            if let createSheet = self.dependencyManager.templateValueOfType( VCreateSheetViewController.self, forKey:"createSheet", withAddedDependencies:addedDependencies ) as? VCreateSheetViewController {
                
                createSheet.completionHandler = { (createSheetViewController, chosenCreationType) in
                    self.chosenCreationType = chosenCreationType
                    self.finishedExecuting()
                }
                self.originViewController.presentViewController(createSheet, animated: true, completion: nil)
            }
            else {
                let message = NSLocalizedString( "GenericFailMessage", comment:"" )
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
                alertController.addAction( UIAlertAction(title: NSLocalizedString( "OK", comment:""), style: .Cancel, handler: nil) )
                self.originViewController.presentViewController( alertController, animated: true, completion: nil)
                self.finishedExecuting()
            }
        }
    }
}
