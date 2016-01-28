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

@objc public class TemplateCache: NSObject {
    public let dataCache: VDataCache
    public let environment: VEnvironment
    public let buildNumber: String
    
    public init(dataCache: VDataCache, environment: VEnvironment, buildNumber: String) {
        self.dataCache = dataCache
        self.environment = environment
        self.buildNumber = buildNumber
    }
    
    public func cachedTemplateData() -> NSData? {
        if let cachedData = dataCache.cachedDataForID(cacheIDForEnvironment(environment)),
            let infoDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(cachedData) as? [String : AnyObject],
            let cachedBuildNumber = infoDictionary[buildNumberDictionaryKey] as? String
            where cachedBuildNumber == buildNumber {
                return infoDictionary[templateDataDictionaryKey] as? NSData
        }
        return nil
    }
    
    public func cacheTemplateData(templateData: NSData) throws {
        let infoDictionary = [buildNumberDictionaryKey: buildNumber, templateDataDictionaryKey: templateData]
        let data = NSKeyedArchiver.archivedDataWithRootObject(infoDictionary)
        try dataCache.cacheData(data, forID: cacheIDForEnvironment(environment))
    }
    
    public func clearTemplateData() throws {
        try dataCache.removeCachedDataForID(cacheIDForEnvironment(environment))
    }
    
    private func cacheIDForEnvironment(environment: VEnvironment) -> String {
        return "template.\(environment.name).data"
    }
}
