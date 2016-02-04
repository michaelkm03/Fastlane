//
//  VTwitterManager.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VTwitterManager {
    func parseQueryComponenets(urlString urlString: String) -> [String : String]? {
        guard let urlComponents = NSURLComponents(string: urlString), let queryItems = urlComponents.queryItems else {
            VLog("Failed to parse url components of urlString: \(urlString)")
            return nil
        }

        var params = [String : String]()
        for queryItem in queryItems {
            params[queryItem.name] = queryItem.value
        }

        return params
    }
}
