//
//  VImageAsset.swift
//  victorious
//
//  Created by Vincent Ho on 5/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData
import VictoriousIOSSDK

@objc(VImageAsset)
class VImageAsset: NSManagedObject, ImageAssetModel {
    @NSManaged var height: NSNumber?
    @NSManaged var imageURL: String
    @NSManaged var width: NSNumber?
    @NSManaged var streamItems: NSSet?
    @NSManaged var user: VUser?
    @NSManaged var content: VContent?
    
    // MARK: - ImageAssetModel
    
    var mediaMetaData: MediaMetaData {
        var size: CGSize? = nil
        if let width = self.width?.floatValue, let height = self.height?.floatValue {
            size = CGSize(width: CGFloat(width), height: CGFloat(height))
        }
        
        // retrievedURL should be valid because it's an non optional property on the network model.
        // But due to Core Data limitations, we lose that information when we store the url as a String in core data
        // So we are doing the following nil coalescing and assertionFailure to catch the programmer error
        let retrievedURL = NSURL(string: imageURL)
        if retrievedURL == nil {
            assertionFailure("Retrieved imageURL should not be nil")
        }
        let validURL = retrievedURL ?? NSURL(string: "")!
        
        return MediaMetaData(url: validURL, size: size)
    }
}
