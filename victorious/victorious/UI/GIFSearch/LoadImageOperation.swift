//
//  StreamToFileOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class LoadImageOperation: NSOperation {
    
    let remoteURL: NSURL
    var error: NSError?
    var image: UIImage?
    
    init( remoteURL: NSURL ) {
        self.remoteURL = remoteURL
    }
    
    override func main() {
        var error: NSError?
        if let previewImageData = NSData(contentsOfURL: self.remoteURL, options: nil, error: &error),
            let image = UIImage(data: previewImageData) {
                self.image = image
        }
    }
    
    var mainQueueCompletionBlock: (()->())? {
        didSet {
            if let block = self.mainQueueCompletionBlock {
                self.completionBlock = {
                    dispatch_async( dispatch_get_main_queue(), block )
                }
            }
        }
    }
}