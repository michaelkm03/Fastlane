//
//  NSURL+MimeType.swift
//  victorious
//
//  Created by Josh Hinman on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import MobileCoreServices
import Foundation

extension NSURL {
    /// Returns the MIME type that matches this URL's extension, or nil if no MIME type could be determined.
    public func vsdk_mimeType() -> String? {
        guard let pathExtension = self.pathExtension else {
            return nil
        }
        if let type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, nil)?.takeRetainedValue(),
           let mimeType = UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType)?.takeRetainedValue() {
            return mimeType as String
        }
        return nil
    }
}
