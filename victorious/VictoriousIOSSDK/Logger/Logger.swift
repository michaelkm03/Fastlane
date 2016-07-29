//
//  Logger.swift
//  victorious
//
//  Created by Sebastian Nystorm on 29/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public final class Logger {

    /// Single logger instance, configured to log to console and SwiftyBeaver remote.
    public static let sharedLogger = Logger()

    private let swiftyBeaverLogger = SwiftyBeaver.self

    private let remoteDestination = SBPlatformDestination(appID: Secrets.appID, appSecret: Secrets.appSecret, encryptionKey: Secrets.encryptionKey)

    private struct Secrets {
        static let appID = "m5OOEr"
        static let appSecret = "Bpjf42wjbtflv6xcaevhrvvo5adhnojU"
        static let encryptionKey = "eZuffjwc7jpjkvqujuweg9nkhi0slleE"
    }

    private init() {
        let consoleDestination = ConsoleDestination()
        swiftyBeaverLogger.addDestination(consoleDestination)
        swiftyBeaverLogger.addDestination(remoteDestination)
    }

    // MARK: - Configuration

    /// Unique identifier of the user, should be set as early as possible.
    public func identifyUser(identifier: String) {
        remoteDestination.analyticsUserName = identifier
    }

    /// Logs to remote async, can be set to `false` during development. Should be `true` on production builds. `true` by default.
    public func logAsynchronously(asynchronously: Bool) {
        remoteDestination.asynchronously = asynchronously
    }

    /// Turn on to show logs in console. `false` by default.
    public func showsNSLogs(nslogs: Bool) {
        remoteDestination.showNSLog = nslogs
    }

    // MARK: - Logging

    public func verbose(message: String) {
        swiftyBeaverLogger.verbose(message)
    }

    public func debug(message: String) {
        swiftyBeaverLogger.debug(message)
    }

    public func info(message: String) {
        swiftyBeaverLogger.info(message)
    }

    public func warning(message: Any) {
        swiftyBeaverLogger.warning(message)
    }

    public func error(message: Any) {
        swiftyBeaverLogger.error(message)
    }
}
