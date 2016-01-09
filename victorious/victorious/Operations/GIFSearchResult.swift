//
//  GIFSearchResult.swift
//  victorious
//
//  Created by Patrick Lynch on 12/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class GIFSearchResultObject: NSObject {
    
    let sourceResult: VictoriousIOSSDK.GIFSearchResult
    var exportPreviewImage: UIImage?
    var exportMediaURL: NSURL?
    
    var aspectRatio: CGFloat {
        return CGFloat(sourceResult.width) / CGFloat(sourceResult.height)
    }
    
    var assetSize: CGSize {
        return CGSize(width: CGFloat(sourceResult.width), height: CGFloat(sourceResult.height))
    }
    
    func remoteID() -> String {
        return sourceResult.remoteID
    }
    
    init( _ value: VictoriousIOSSDK.GIFSearchResult ) {
        self.sourceResult = value
    }
}
