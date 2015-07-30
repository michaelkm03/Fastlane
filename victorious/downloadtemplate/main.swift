//
//  main.swift
//  downloadtemplate
//
//  Created by Josh Hinman on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

let appName = Process.arguments.first ?? "downloadtemplate"
let usage = "Usage: \(appName.lastPathComponent) <path to application bundle>\n"
let environmentsFilename = "environments.plist"

if Process.arguments.count < 2 {
    println(usage)
    exit(1)
}
let bundlePath = Process.arguments[1]

if let bundleURL = NSURL(fileURLWithPath: bundlePath, isDirectory: true) {
    let cli = TemplateDownloadCLI(bundleURL: bundleURL)
    cli.downloadTemplate()
}
else {
    println("Invalid bundle: \(bundlePath)\n")
    exit(1)
}