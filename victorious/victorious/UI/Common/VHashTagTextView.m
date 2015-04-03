//
//  VHashTagTextView.m
//  victorious
//
//  Created by Michael Sena on 11/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHashTagTextView.h"


// Formatting
#import "VThemeManager.h"
#import "VHashTags.h"

@implementation VHashTagTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame
                  textContainer:textContainer];
    if (self)
    {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.minimumPressDuration = 99999.0f;
    UIColor *linkForegroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    if (linkForegroundColor != nil)
    {
        self.linkTextAttributes = @{
                                    NSForegroundColorAttributeName : linkForegroundColor,
                                        };
    }
    
    UIColor *highlightedLinkForegroundColor = [linkForegroundColor colorWithAlphaComponent:0.5f];
    if (highlightedLinkForegroundColor)
    {
        self.linkTextTouchAttributes = @{
                                         NSForegroundColorAttributeName : highlightedLinkForegroundColor,
                                         };
    }
    
}

#pragma mark - UITextView Overrides

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    NSMutableAttributedString *linkedAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    
    NSArray *hashTagRanges = [VHashTags detectHashTags:attributedText.string];
    [hashTagRanges enumerateObjectsUsingBlock:^(NSValue *enumeratedRangeValue, NSUInteger idx, BOOL *stop)
     {
         NSRange rangeFromValue = [enumeratedRangeValue rangeValue];
         [linkedAttributedString addAttribute:CCHLinkAttributeName
                                        value:[linkedAttributedString.string substringWithRange:rangeFromValue]
                                        range:NSMakeRange(rangeFromValue.location-1, rangeFromValue.length+1)]; // To accomodate leading "#" character
     }];

    [super setAttributedText:[[NSAttributedString alloc] initWithAttributedString:linkedAttributedString]];
}

@end
