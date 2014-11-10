//
//  VTappableTextManager.m
//  victorious
//
//  Created by Patrick Lynch on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTappableTextManager.h"

@interface VTappableTextManager()

/**
 Performs the actual detection of tappable text in the supplied textview and calls the callback when tappable text exists at the supplied tap point.
 @return BOOL Indicates whether or not preliminary error checking succeeded, not whether tappable text was detected.
 */
- (BOOL)findTextInTextView:(UITextView *)textView atPoint:(CGPoint)tapPoint detectionCallback:(void (^)(NSString *text))callback;

@property (nonatomic, weak) id<VTappableTextManagerDelegate> delegate;

@end

@implementation VTappableTextManager

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

- (void)setDelegate:(id<VTappableTextManagerDelegate>)delegate
{
    NSError *error = nil;
    NSAssert( [self validateDelegate:delegate error:&error], @"%@", error.domain );
    _delegate = delegate;
}

- (void)unsetDelegate
{
    _delegate = nil;
}

- (BOOL)validateDelegate:(id<VTappableTextManagerDelegate>)delegate error:(NSError**)error
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
        
        // Detect tappable text
        [self findTextInTextView:textView atPoint:[tap locationInView:textView] detectionCallback:^(NSString *text) {
            if ( [self.delegate respondsToSelector:@selector(text:tappedInTextView:)] )
            {
                [self.delegate text:text tappedInTextView:textView];
            }
        }];
    }
}

- (NSArray *)rangesOfStrings:(NSArray *)stringsArray inText:(NSString *)text
{
    NSMutableArray *container = [[NSMutableArray alloc] init];
    [stringsArray enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop)
    {
        NSRange range = [text rangeOfString:string];
        NSValue *value = [NSValue valueWithRange:range];
        [container addObject:value];
    }];
    return [NSArray arrayWithArray:container];
}

- (BOOL)findTextInTextView:(UITextView *)textView atPoint:(CGPoint)tapPoint detectionCallback:(void (^)(NSString *text))callback
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
    // Quick optimization
    if ( self.tappableTextRanges.count == 0 )
    {
        return YES;
    }
    
    [self.tappableTextRanges enumerateObjectsUsingBlock:^(NSValue *valueObject, NSUInteger idx, BOOL *stop) {
        
        NSRange tagRange = [valueObject rangeValue];
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
