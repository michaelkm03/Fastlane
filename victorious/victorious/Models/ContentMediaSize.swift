//
//  ContentMediaSize.swift
//  victorious
//
//  Created by Jarod Long on 6/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A struct that contains a content's media size and aspect ratio information.
struct ContentMediaSize: Equatable {
    
    // MARK: - Size and aspect ratio information
    
    /// The size's aspect ratio.
    var aspectRatio: CGFloat
    
    /// The preferred width to use when displaying content media of this size.
    var preferredWidth: CGFloat
    
    /// The preferred height to use when displaying content media of this size.
    var preferredHeight: CGFloat {
        return ContentMediaSize.height(fromWidth: preferredWidth, aspectRatio: aspectRatio)
    }
    
    /// The preferred height to use when displaying content media of this size.
    var preferredSize: CGSize {
        return CGSize(width: preferredWidth, height: preferredHeight)
    }
    
    /// The preferred height to use when displaying content media of this size, clamped to the given maximum width
    /// while maintaining the correct aspect ratio.
    func preferredSize(clampedToWidth maxWidth: CGFloat) -> CGSize {
        let width = min(maxWidth, preferredWidth)
        return CGSize(width: width, height: ContentMediaSize.height(fromWidth: width, aspectRatio: aspectRatio))
    }
    
    fileprivate static func height(fromWidth width: CGFloat, aspectRatio: CGFloat) -> CGFloat {
        return aspectRatio == 0.0 ? 0.0 : width / aspectRatio
    }
    
    // MARK: - Supported sizes
    
    /// The list of sizes defined by the design which we support for displaying content.
    static let supportedSizes = [
        ContentMediaSize(aspectRatio: 3.0  / 4.0,  preferredWidth: 156.0),
        ContentMediaSize(aspectRatio: 1.0  / 1.0,  preferredWidth: 180.0),
        ContentMediaSize(aspectRatio: 4.0  / 5.0,  preferredWidth: 160.0),
        ContentMediaSize(aspectRatio: 3.0  / 2.0,  preferredWidth: 205.5),
        ContentMediaSize(aspectRatio: 2.0  / 3.0,  preferredWidth: 147.0),
        ContentMediaSize(aspectRatio: 4.0  / 3.0,  preferredWidth: 208.0),
        ContentMediaSize(aspectRatio: 5.0  / 4.0,  preferredWidth: 200.0),
        ContentMediaSize(aspectRatio: 16.0 / 9.0,  preferredWidth: 240.0),
        ContentMediaSize(aspectRatio: 9.0  / 16.0, preferredWidth: 135.0)
    ]
    
    /// Returns a supported size that best matches the given `aspectRatio`.
    static func supportedSize(closestToAspectRatio aspectRatio: CGFloat) -> ContentMediaSize {
        let bestSize = supportedSizes.select { currentSize, potentialSize in
            return fabs(potentialSize.aspectRatio - aspectRatio) < fabs(currentSize.aspectRatio - aspectRatio)
        }
        
        if let bestSize = bestSize {
            return bestSize
        }
        else {
            assertionFailure("Failed to retrieve a supported content size.")
            return ContentMediaSize(aspectRatio: 1.0, preferredWidth: 200.0)
        }
    }
}

func == (lhs: ContentMediaSize, rhs: ContentMediaSize) -> Bool {
    return lhs.aspectRatio == rhs.aspectRatio && lhs.preferredWidth == rhs.preferredWidth
}
