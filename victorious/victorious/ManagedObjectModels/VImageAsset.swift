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
    @NSManaged var height: NSNumber
    @NSManaged var imageURL: String
    @NSManaged var width: NSNumber
    @NSManaged var streamItems: NSSet?
    @NSManaged var user: VUser?
    @NSManaged var content: VContent?
    
    // MARK: - ImageAssetModel
    
    var imageSource: ImageSource {
        return ImageSource.remote(url: NSURL(string: imageURL)!)
    }
    
    var size: CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}
