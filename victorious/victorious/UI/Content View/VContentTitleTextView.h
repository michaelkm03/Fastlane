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

- (void)textLayoutHappenedInContentTitleTextView:(VContentTitleTextView *)contentTitleTextView; ///< Notifies the delegate that the text has been placed into the container
- (void)seeMoreButtonTappedInContentTitleTextView:(VContentTitleTextView *)contentTitleTextView; ///< Notifies the delegate that the user tapped the "see more" button
- (void)hashTagButtonTappedInContentTitleTextView:(VContentTitleTextView *)contentTitleTextView withTag:(NSString *)tag; ///< Notifies the delegate that the user tapped a hash tag button in the header

@end

/**
 Displays the title in a content view with a "read more" button, if necessary
 */
@interface VContentTitleTextView : UIView

@property (nonatomic, weak)     IBOutlet id<VContentTitleTextViewDelegate>  delegate;
@property (nonatomic, copy)     NSString                                   *text;

/**
 Y-coordinate of the bottom of the last line of text, in 
 the receiver's coordinates. If you're doing anything 
 with this value, listen for the 
 textLayoutHappenedInContentTitleTextView: delegate 
 method, which signals that this value may have changed.
 */
@property (nonatomic, readonly) CGFloat locationForLastLineOfText;

@end
