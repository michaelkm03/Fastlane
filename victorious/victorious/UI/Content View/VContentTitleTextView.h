//
//  VContentTitleTextView.h
//  victorious
//
//  Created by Josh Hinman on 5/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VContentTitleTextView;

@protocol VContentTitleTextViewDelegate <NSObject>

@optional

- (void)seeMoreButtonTappedInContentTitleTextView:(VContentTitleTextView *)contentTitleTextView;

@end

/**
 Displays the title in a content view with a "read more" button, if necessary
 */
@interface VContentTitleTextView : UIView

@property (nonatomic, weak) id<VContentTitleTextViewDelegate>  delegate;
@property (nonatomic, copy) NSString                          *text;

@end
