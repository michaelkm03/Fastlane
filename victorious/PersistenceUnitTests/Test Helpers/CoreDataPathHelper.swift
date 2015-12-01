//
//  CoreDataPathHelper.swift
//  VictoriousIOSSDK
//
//  Created by Patrick Lynch on 10/19/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation
@testable import victorious

struct CoreDataPathHelper {
    
    func URLForManagedObjectModelInBundle( versionedModelName: String, modelVersion: String ) -> NSURL {
        let fullPath = ("\(versionedModelName).momd" as NSString).stringByAppendingPathComponent( modelVersion )
        return NSBundle(forClass: CoreDataManager.self).URLForResource( fullPath, withExtension: "mom" )!
    }
    
    var applicationDocumentsDirectory: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last!
    }
    
    func deleteFilesInDirectory( directory: NSURL ) {
        
        for url in NSFileManager.defaultManager().enumeratorAtURL( directory, includingPropertiesForKeys: nil, options: [], errorHandler: nil )! {
            do { try NSFileManager.defaultManager().removeItemAtURL( url as! NSURL ) }
            catch {}
        }
    }
}