//
//  GIFSearchResult+RestKit.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

// Provides the RestKit mapping and descriptors needed for GIFSearchResult model
extension GIFSearchResult {
    
    override static func entityMapping() -> RKEntityMapping {
        let propertyMap = [
            "gif_url"           : "gifUrl",
            "gif_size"          : "gifSize",
            "mp4_url"           : "mp4Url",
            "mp4_size"          : "mp4Size",
            "frames"            : "frames",
            "width"             : "width",
            "height"            : "height",
            "thumbnail"         : "thumbnailUrl",
            "thumbnail_still"   : "thumbnailStillUrl",
            "remote_id"         : "remoteId" ]
        
        let store = RKObjectManager.sharedManager().managedObjectStore
        let mapping = RKEntityMapping(forEntityForName: self.v_entityName(), inManagedObjectStore: store )
        mapping.addAttributeMappingsFromDictionary( propertyMap )
        mapping.identificationAttributes = [ "gifUrl", "mp4Url" ]
        return mapping
    }
    
    static var descriptors: NSArray {
        return [
            RKResponseDescriptor(
                mapping: self.entityMapping(),
                method: RKRequestMethod.GET,
                pathPattern: "/api/image/gif_search/:search_term/:page/:perpage",
                keyPath: "payload",
                statusCodes: RKStatusCodeIndexSetForClass(.Successful)
            ),
            
            RKResponseDescriptor(
                mapping: self.entityMapping(),
                method: RKRequestMethod.GET,
                pathPattern: "/api/image/trending_gifs/:page/:perpage",
                keyPath: "payload",
                statusCodes: RKStatusCodeIndexSetForClass(.Successful)
            )
        ]
    }
}