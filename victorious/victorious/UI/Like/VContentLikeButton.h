//
//  VContentLikeButton.h
//  victorious
//
//  Created by Patrick Lynch on 6/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A simple toggle like/unlike button and a label that shows like count.
 */
@interface VContentLikeButton : UIButton

/**
 If passing YES, displays the like button in the 'liked' state, designed
 to indicate the user has liked whatever content is being displayed.
 */
- (void)setActive:(BOOL)active;

/**
 Sets the text of the count label according to the app's standard number formatting.
 */
- (void)setCount:(NSUInteger)count;

- (void)show;

- (void)hide;

@end
