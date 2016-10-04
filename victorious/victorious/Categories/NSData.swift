//
//  NSData.swift
//  victorious
//
//  Created by Sebastian Nystorm on 21/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension NSData {

    ///
    /// This function will do it's best with reasonable amounts of resources to guess the content type of the possible image.
    /// Supported formats are:
    /// - jpeg
    /// - png
    /// - gif
    /// - tiff
    ///
    /// NOTE: Calling this function on an NSData not generated from an image could give unexpected results.
    ///
    func imageType() -> (contentType: String, fileExtension: String)? {
        // Adapted solution from: http://stackoverflow.com/a/5042365/154915

        var byte: UInt8 = 0
        getBytes(&byte, length: MemoryLayout<UInt8>.size)

        var contentType: String?
        var fileExtension: String?

        switch byte {
            case 0xFF:
                contentType = "image/jpeg"
                fileExtension = "jpeg"
            case 0x89:
                contentType = "image/png"
                fileExtension = "png"
            case 0x47:
                contentType = "image/gif"
                fileExtension = "gif"
            case 0x49, 0x4D:
                contentType = "image/tiff"
                fileExtension = "tiff"
            default: ()
        }

        guard let type = contentType, let fileExt = fileExtension else {
            return nil
        }

        return (contentType: type, fileExtension: fileExt)
    }
}
