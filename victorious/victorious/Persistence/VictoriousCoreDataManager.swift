//
//  VictoriousCoreDataManager.swift
//  victorious
//
//  Created by Patrick Lynch on 11/5/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// TODO
/// This file has some less-than-ideal convenience methods to support easy integration.
/// A better non-global, non-Singleton API would be preferred.

private struct VictoriousCoreDataManager {
    
    private static var instance: CoreDataManager? = nil
    
    static let persistentStorePath = "victoriOS.sqlite"
    static let managedObjectModelName = "victoriOS"
    static let version = "victorious-4.0"
    
    private static var sharedManager: CoreDataManager {
        if instance == nil {
            let docsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let persistentStoreURL = docsDirectory.URLByAppendingPathComponent( persistentStorePath )
            
            let momPath = ("\(managedObjectModelName).momd" as NSString).stringByAppendingPathComponent( version )
            guard let momURLInBundle = NSBundle.mainBundle().URLForResource( momPath, withExtension: "mom" ) else {
                fatalError( "Cannot find managed object model (.mom) for URL in bundle: \(momPath)" )
            }
            
            instance = CoreDataManager(
                persistentStoreURL: persistentStoreURL,
                currentModelVersion: CoreDataManager.ModelVersion(
                    identifier: version,
                    managedObjectModelURL: momURLInBundle
                ),
                previousModelVersion: nil
            )
        }
        return instance!
    }
}