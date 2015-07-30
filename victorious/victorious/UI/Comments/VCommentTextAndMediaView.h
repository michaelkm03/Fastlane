//
//  VCommentTextAndMediaView.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextAndMediaView.h"
#import "VComment.h"

@interface VCommentTextAndMediaView : VTextAndMediaView

@property (nonatomic, strong) VComment *comment;

/**
 Returns the ideal height for instances of this view
 given specific width, text, font, and whether or not
 we need room for a media thumbnail.
 */
+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width comment:(VComment *)comment andFont:(UIFont *)font;

/**
 Same as above but without a custom font.
 */
+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width comment:(VComment *)comment;

@end
