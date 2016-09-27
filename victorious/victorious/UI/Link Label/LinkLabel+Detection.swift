//
//  LinkLabel+Detection.swift
//  victorious
//
//  Created by Jarod Long on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension LinkLabel {
    /// Sets the link detectors of the label to detect `content`'s user tags, calling `callback` with the corresponding
    /// URL when a link is tapped.
    func detectUserTags(for content: Content?, callback: (_ url: NSURL) -> Void) {
        linkDetectors = content?.userTags.map { username, url in
            return SubstringLinkDetector(substring: "@\(username)") { _ in
                callback(url: url)
            }
        } ?? []
    }
}
