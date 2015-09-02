//
//  ContentDetailViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 9/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ContentDetailOptions: NSObject {
    var assetPreviewView: UIView?
    var dismissalCallback:(()->())?
}

class ContentDetailViewController: UIViewController {
    
    var options: ContentDetailOptions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.redColor()
        
        if let preview = self.options.assetPreviewView {
            preview.frame = UIApplication.sharedApplication().delegate!.window!!.convertRect( preview.frame, fromView: preview )
            self.view.addSubview(preview)
        }
        
        dispatch_after(2.0) {
            self.options.dismissalCallback?()
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
