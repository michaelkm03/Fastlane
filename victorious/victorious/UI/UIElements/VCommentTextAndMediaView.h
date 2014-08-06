//
//  VCommentTextAndMediaView.h
//  victorious
//
//  Created by Josh Hinman on 8/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This view is used inside the comment and messaging views
 to display comment text and any media that might
 be attached to the comment.
 */
@interface VCommentTextAndMediaView : UIView

@property (nonatomic, copy) NSString *text;

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text;

@end
