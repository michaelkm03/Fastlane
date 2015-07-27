//
//  VInStreamMediaLink.h
//  victorious
//
//  Created by Sharif Ahmed on 7/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCommentMediaType.h"

@class VDependencyManager;

/**
    A model for populating a media link button within an in stream comment.
 */
@interface VInStreamMediaLink : NSObject

/**
    Creates and returns a new VInStreamMediaLink based on the provided fields.
 */
- (instancetype)initWithTintColor:(UIColor *)tintColor
                             font:(UIFont *)font
                             text:(NSString *)text
                             icon:(UIImage *)icon
                         linkType:(VCommentMediaType)linkType
                        urlString:(NSString *)urlString;

/**
    Creates and returns a new VInStreamMediaLink based on the provided fields. Gets images for
        in stream comments from the provided dependency manager.
 */
+ (instancetype)newWithTintColor:(UIColor *)tintColor
                            font:(UIFont *)font
                        linkType:(VCommentMediaType)linkType
                       urlString:(NSString *)urlString
            andDependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, readonly) UIColor *tintColor; ///< The color of the image and text in the link button
@property (nonatomic, readonly) UIFont *font; ///< The font of the label of the link button
@property (nonatomic, readonly) NSString *text; ///< The text that should be displayed in the link button
@property (nonatomic, readonly) UIImage *icon; ///< The icon that should be displayed in the link button
@property (nonatomic, readonly) VCommentMediaType mediaLinkType; ///< The type of media represented by the link button
@property (nonatomic, readonly) NSString *urlString; ///< A string representing the url of the media represented by the link button

@end
