//
//  Logger.swift
//  victorious
//
//  Created by Sebastian Nystorm on 29/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

private struct Secrets {
    static let appID = "m5OOEr"
    static let appSecret = "Bpjf42wjbtflv6xcaevhrvvo5adhnojU"
    static let encryptionKey = "eZuffjwc7jpjkvqujuweg9nkhi0slleE"
}

private struct Config {
    /// Logs to remote async, can be set to `false` during development. Should be `true` on production builds. `true` by default.
    static let logAsynchronously = true

    /// Turn on to show logs in console even if on production build. `false` by default.
    static let showNSLog = false
}

public var logger: SwiftyBeaver.Type = {
    let theBeaver = SwiftyBeaver.self

    #if DEBUG
        let consoleDestination = ConsoleDestination()
        consoleDestination.colored = false
        theBeaver.addDestination(consoleDestination)
    #else
        let remoteDestination = SBPlatformDestination(appID: Secrets.appID, appSecret: Secrets.appSecret, encryptionKey: Secrets.encryptionKey)
        remoteDestination.asynchronously = Config.logAsynchronously
        remoteDestination.showNSLog = Config.showNSLog
        theBeaver.addDestination(remoteDestination)
    #endif

    return theBeaver
}()

public extension SwiftyBeaver {
    private class var platformDestination: SBPlatformDestination? {
        return destinations.flatMap { $0 as? SBPlatformDestination }.first
    }

    /// Unique identifier of the user, should be set as early as possible.
    class func setUserIdentifier(identifier: String) {
        platformDestination?.analyticsUserName = identifier
    }
}
