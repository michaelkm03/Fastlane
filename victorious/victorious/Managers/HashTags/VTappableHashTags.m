//
//  VTappableHashTags.m
//  victorious
//
//  Created by Patrick Lynch on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTappableHashTags.h"
#import "VHashTags.h"

@interface VTappableHashTags()

/**
 Performs the actual detection of hashtags in the supplied textview and calls the callback when a
 hashtag exists at the supplied tap point.
 @return BOOL Indicates whether or not preliminary error checking succeeded, not whether a hash tag was detected.
 */
- (BOOL)detectHashTagsInTextView:(UITextView *)textView atPoint:(CGPoint)tapPoint detectionCallback:(void (^)(NSString *hashTag))callback;

@property (nonatomic, weak) id<VTappableHashTagsDelegate> delegate;

@end

@implementation VTappableHashTags

- (UITextView *)createTappableTextViewWithFrame:(CGRect)frame
{
    if ( !self.hasValidDelegate )
    {
        return nil;
    }
    UITextView *textView = [[UITextView alloc] initWithFrame:frame textContainer:self.delegate.textContainer];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.editable = NO;
    textView.selectable = NO;
    textView.scrollEnabled = NO;
    textView.textContainerInset = UIEdgeInsetsZero; // leave this as zero. To inset the text, adjust the textView's frame instead.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
    [textView addGestureRecognizer:tap];
    
    return textView;
}

- (BOOL)hasValidDelegate
{
    return _delegate != nil;
}

- (BOOL)setDelegate:(id<VTappableHashTagsDelegate>)delegate error:(NSError**)error
{
    if ( [self validateDelegate:delegate error:error] )
    {
        _delegate = delegate;
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)unsetDelegate
{
    _delegate = nil;
}

- (BOOL)validateDelegate:(id<VTappableHashTagsDelegate>)delegate error:(NSError**)error
{
    NSString *errorMessage = nil;
    
    if ( delegate == nil )
    {
        errorMessage = @"Delegate is nil.";
    }
    else if ( [delegate textStorage] == nil )
    {
        errorMessage = @"Delegate's 'textStorage' property/selector must return a valid NSTextStorage";
    }
    else if ( [delegate containerLayoutManager] == nil )
    {
        errorMessage = @"Delegate's 'layoutManager' property/selector must return a valid NSLayoutManager";
    }
    else if ( [delegate textContainer] == nil )
    {
        errorMessage = @"Delegate's 'textContainer' property/selector must return a valid NSTextContainer";
    }
    else if ( ![[[delegate containerLayoutManager] textContainers] containsObject:[delegate textContainer]] )
    {
        errorMessage = @"Delegate's 'layoutManager' must contain its textContainer.  See 'addTextContainer' on NSLayoutManager";
    }
    else if ( ![[[delegate textStorage] layoutManagers] containsObject:[delegate containerLayoutManager]] )
    {
        errorMessage = @"Delegate's 'textStorage' must contain its layoutManager.  See 'addLayoutManager' on NSTextStorage";
    }
    
    if ( errorMessage != nil )
    {
        if ( error != nil )
        {
            *error = [NSError errorWithDomain:errorMessage code:0 userInfo:nil];
        }
        return NO;
    }
    
    return YES;
}

- (void)textTapped:(UITapGestureRecognizer *)tap
{
    if ( tap.view != nil && [tap.view isKindOfClass:[UITextView class]] )
    {
        UITextView *textView = (UITextView *)tap.view;
        [self detectHashTagsInTextView:textView atPoint:[tap locationInView:textView] detectionCallback:^(NSString *hashTag) {
            if ( [self.delegate respondsToSelector:@selector(hashTag:tappedInTextView:)] )
            {
                [self.delegate hashTag:hashTag tappedInTextView:textView];
            }
        }];
    }
}

- (BOOL)detectHashTagsInTextView:(UITextView *)textView atPoint:(CGPoint)tapPoint detectionCallback:(void (^)(NSString *hashTag))callback
{
    // Error checking
    if ( !self.hasValidDelegate || textView == nil || textView.text.length == 0 )
    {
        return NO;
    }
    else if (  textView.layoutManager != [_delegate containerLayoutManager] || textView.textContainer != [_delegate textContainer] )
    {
        return NO;
    }
    
    NSString *fieldText = textView.text;
    NSArray *hashTags = [VHashTags detectHashTags:fieldText];
    // Quick optimization
    if ( hashTags.count == 0 )
    {
        return YES;
    }
    
    [hashTags enumerateObjectsUsingBlock:^(NSValue *hastagRangeValue, NSUInteger idx, BOOL *stop) {
        
        NSRange tagRange = [hastagRangeValue rangeValue];
        CGRect rect = [textView.layoutManager boundingRectForGlyphRange:tagRange inTextContainer:textView.textContainer];
        NSUInteger margin = 10;
        rect.origin.y -= margin;
        rect.size.height += margin * 2.0;
        if ( CGRectContainsPoint(rect, tapPoint) )
        {
            if ( callback != nil )
            {
                callback( [fieldText substringWithRange:tagRange] );
            }
            *stop = YES;
        }
    }];
    
    return YES;
}

@end
