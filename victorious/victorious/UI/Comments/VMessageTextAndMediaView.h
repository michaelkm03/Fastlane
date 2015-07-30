//
//  VMessageTextAndMediaView.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextAndMediaView.h"
#import "VMessage.h"

@interface VMessageTextAndMediaView : VTextAndMediaView

@property (nonatomic, strong) VMessage *message;

/**
 Returns the ideal height for instances of this view
 given specific width, text, font, and whether or not
 we need room for a media thumbnail.
 */
+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width message:(VMessage *)message andFont:(UIFont *)font;

/**
 Same as above but without a custom font.
 */+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width message:(VMessage *)message;

@end
