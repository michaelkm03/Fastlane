//
//  main.swift
//  downloadtemplate
//
//  Created by Josh Hinman on 7/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

let appName = Process.arguments.first ?? "downloadtemplate"
let usage = "Usage: \((appName as NSString).lastPathComponent) <path to application bundle> [environment name]\n"
let environmentsFilename = "environments.plist"

if Process.arguments.count < 2 {
    print(usage)
    exit(1)
}
let bundlePath = Process.arguments[1]

var environmentName: String? = nil
if Process.arguments.count >= 3 {
    environmentName = Process.arguments[2]
}

let cli = TemplateDownloadCLI(bundleURL: NSURL(fileURLWithPath: bundlePath, isDirectory: true))
cli.downloadTemplate(environmentName: environmentName)
