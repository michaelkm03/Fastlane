//
//  VTappableTextManager.h
//  victorious
//
//  Created by Patrick Lynch on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VTappableTextManagerDelegate <NSObject>

@required
- (NSTextStorage *)textStorage;
- (NSLayoutManager *)containerLayoutManager;
- (NSTextContainer *)textContainer;

@optional
- (void)text:(NSString *)text tappedInTextView:(UITextView *)textView;
- (void)textView:(UITextView *)textView tappedWithTap:(UIGestureRecognizer *)tap;

@end

/**
 A class that facilitates tappable text in a UITextView that displays an attributed string.
 */
@interface VTappableTextManager : NSObject

/**
 Used internally for error checking.
 */
@property (nonatomic, readonly) BOOL hasValidDelegate;

@property (nonatomic, strong) NSArray *tappableTextRanges;

/**
 Creates and returns a UITextView instance that is configured to work with text tapping routines in this class.
 Also adds a tap gesture recognizer and handles all input until a span of text is detect and the delegate's main method is called.
 */
- (UITextView *)createTappableTextViewWithFrame:(CGRect)frame;

/**
 Use this method to set the delegate.  There are some specific requirements for this delegate
 that go beyond simply conforming to a protocol, so make sure to check the return value and
 read the error message if something's not working/
 */
- (BOOL)setDelegate:(id<VTappableTextManagerDelegate>)delegate error:(NSError**)error;

/**
 Sets the internally (weak) referenced delegate to nil.  This is provided because the delegate
 is not a simple property that can be set more freely, but instead uses the setDelegate:error:
 method to validate the delegate first.
 */
- (void)unsetDelegate;

@end
