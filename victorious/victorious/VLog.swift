//
//  VLog.swift
//  victorious
//
//  Created by Josh Hinman on 2/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

func v_log(message: String, filename: String = #file, functionName: String = #function, line: Int = #line) {
    let logMessage = "\(filename): \(functionName) [Line \(line)] \(message)"
#if DEBUG
    NSLog(logMessage)
#endif
}
