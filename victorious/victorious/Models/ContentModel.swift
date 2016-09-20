//
//  ContentModel.swift
//  victorious
//
//  Created by Tian Lan on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

extension ContentModel {
    // MARK: - Author information
    
    var wasCreatedByCurrentUser: Bool {
        return author.id == VCurrentUser.user?.id
    }
    
    // MARK: - Media size
    
    /// The natural aspect ratio of the content's media, or nil if the content does not have any media.
    ///
    /// This may not correspond to a supported aspect ratio value. Use the `mediaSize` property if you need a supported
    /// aspect ratio.
    ///
    var naturalMediaAspectRatio: CGFloat? {
        return assets.first?.size?.aspectRatio ?? previewImages.first?.size.aspectRatio
    }
    
    /// The sizing information for the content's media, or nil if the content does not have any media.
    ///
    /// This size will be mapped to the closest supported aspect ratio.
    ///
    var mediaSize: ContentMediaSize? {
        guard let aspectRatio = naturalMediaAspectRatio else {
            return nil
        }
        
        return ContentMediaSize.supportedSize(closestToAspectRatio: aspectRatio)
    }
}

extension Content: PaginatableItem {}
