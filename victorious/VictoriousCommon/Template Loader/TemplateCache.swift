//
//  TemplateCache.swift
//  victorious
//
//  Created by Josh Hinman on 1/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private let buildNumberDictionaryKey = "build"
private let templateDataDictionaryKey = "template"

@objc open class TemplateCache: NSObject {
    open let dataCache: VDataCache
    open let environment: VEnvironment
    open let buildNumber: String
    
    public init(dataCache: VDataCache, environment: VEnvironment, buildNumber: String) {
        self.dataCache = dataCache
        self.environment = environment
        self.buildNumber = buildNumber
    }
    
    open func cachedTemplateData() -> Data? {
        if let cachedData = dataCache.cachedData(for: cacheIDForEnvironment(environment) as VDataCacheID),
            let infoDictionary = NSKeyedUnarchiver.unarchiveObject(with: cachedData) as? [String: AnyObject],
            let cachedBuildNumber = infoDictionary[buildNumberDictionaryKey] as? String
            , cachedBuildNumber == buildNumber {
                return infoDictionary[templateDataDictionaryKey] as? Data
        }
        return nil
    }
    
    open func cacheTemplateData(_ templateData: Data) throws {
        let infoDictionary = [buildNumberDictionaryKey: buildNumber, templateDataDictionaryKey: templateData] as [String : Any]
        let data = NSKeyedArchiver.archivedData(withRootObject: infoDictionary)
        try dataCache.cacheData(data, for: cacheIDForEnvironment(environment) as VDataCacheID)
    }
    
    open func clearTemplateData() throws {
        try dataCache.removeCachedData(for: cacheIDForEnvironment(environment) as VDataCacheID)
    }
    
    fileprivate func cacheIDForEnvironment(_ environment: VEnvironment) -> String {
        return "template.\(environment.name).data"
    }
}
