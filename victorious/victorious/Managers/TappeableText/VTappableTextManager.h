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
 Returns an array of NSValue-wrapped NSRanges of where each string exists in the text.
 @param stringsArray Array of NSString objects from which to generate ranges.
 @param text A string in which the ranges indicate the presence of each string in stringsArray
 */
- (NSArray *)rangesOfStrings:(NSArray *)stringsArray inText:(NSString *)text;

/**
 Creates and returns a UITextView instance that is configured to work with text tapping routines in this class.
 Also adds a tap gesture recognizer and handles all input until a span of text is detect and the delegate's main method is called.
 */
- (UITextView *)createTappableTextViewWithFrame:(CGRect)frame;

/**
 Use this method to set the delegate.
 */
- (void)setDelegate:(id<VTappableTextManagerDelegate>)delegate;

/**
 Sets the internally (weak) referenced delegate to nil.  This is provided because the delegate
 is not a simple property that can be set more freely, but instead uses the setDelegate:error:
 method to validate the delegate first.
 */
- (void)unsetDelegate;

@end
