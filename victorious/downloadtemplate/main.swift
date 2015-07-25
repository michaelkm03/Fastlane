//
//  main.swift
//  downloadtemplate
//
//  Created by Josh Hinman on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Darwin
import Foundation

let appName = Process.arguments.first ?? "downloadtemplate"
let usage = "Usage: \(appName) <path to application bundle> <build number> <version number>\n\n"
let environmentsFilename = "environments.plist"

if Process.arguments.count < 4 {
    fputs(usage, __stderrp)
    exit(1)
}
let bundlePath = Process.arguments[1]
let buildNumber = Process.arguments[2]
let versionNumber = Process.arguments[3]

if let bundleURL = NSURL(fileURLWithPath: bundlePath, isDirectory: true) {
    let cli = TemplateDownloadCLI(bundleURL: bundleURL, buildNumber: buildNumber, versionNumber: versionNumber)
    cli.downloadTemplate()
}
else {
    fputs("Invalid bundle: \(bundlePath)\n\n", __stderrp)
    exit(1)
}
