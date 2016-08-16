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

    /// The minimum log level for *all* destinations registered. Default value is `info`.
    static let minimumLogLevel = SwiftyBeaver.Level.Info
}

/// A class that exposes static methods for logging to SwiftyBeaver.
public final class Log {
    // MARK: - Accessing the beaver
    
    private static let beaver: SwiftyBeaver.Type = {
        let theBeaver = SwiftyBeaver.self

        #if DEBUG
            let consoleDestination = ConsoleDestination()
            consoleDestination.colored = false
            consoleDestination.minLevel = Config.minimumLogLevel
            theBeaver.addDestination(consoleDestination)
        #else
            let remoteDestination = SBPlatformDestination(appID: Secrets.appID, appSecret: Secrets.appSecret, encryptionKey: Secrets.encryptionKey)
            remoteDestination.asynchronously = Config.logAsynchronously
            remoteDestination.showNSLog = Config.showNSLog
            remoteDestination.minLevel = Config.minimumLogLevel
            theBeaver.addDestination(remoteDestination)
        #endif

        return theBeaver
    }()
    
    private static var platformDestination: SBPlatformDestination? {
        return beaver.destinations.flatMap { $0 as? SBPlatformDestination }.first
    }
    
    // MARK: - Configuring
    
    /// Unique identifier of the user, should be set as early as possible.
    public static func setUserIdentifier(identifier: String) {
        platformDestination?.analyticsUserName = identifier
    }
    
    // MARK: - Logging
    
    /// Logs a verbose message. Not visible by default.
    ///
    /// This should be used for spammy debugging messages that can help with diagnosing issues during development.
    ///
    public static func verbose(@autoclosure message: () -> Any, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        beaver.verbose(message, String(file), String(function), line: Int(line))
    }
    
    /// Logs a debug message. Not visible by default.
    ///
    /// This should be used for high-level debugging messages such as websocket events to help with diagnosing issues
    /// during development.
    ///
    public static func debug(@autoclosure message: () -> Any, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        beaver.debug(message, String(file), String(function), line: Int(line))
    }
    
    /// Logs an info message. Visible by default.
    ///
    /// This should be used to log a message that doesn't indicate a serious issue but is still something you would
    /// generally like to know about when it happens.
    ///
    /// Because this logs to the console and the platform by default, this shouldn't be used for things that happen
    /// under normal circumstances to keep our logs clean.
    ///
    public static func info(@autoclosure message: () -> Any, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        beaver.info(message, String(file), String(function), line: Int(line))
    }
    
    /// Logs a warning message. Visible by default.
    ///
    /// This should be used to log serious issues that are presumed to be caused by an external dependency rather than
    /// a programming error, such as an HTTP request failure or parsing error.
    ///
    public static func warning(@autoclosure message: () -> Any, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        beaver.warning(message, String(file), String(function), line: Int(line))
    }
    
    /// Logs an error message. Visible by default and triggers an assertion failure.
    ///
    /// This should be used to log serious errors that indicate a programming error and should halt execution during
    /// development.
    ///
    public static func error(@autoclosure message: () -> Any, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        assertionFailure("\(message())", file: file, line: line)
        beaver.error(message, String(file), String(function), line: Int(line))
    }
}
