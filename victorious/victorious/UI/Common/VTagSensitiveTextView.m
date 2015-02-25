//
//  VTagSensitiveTextView.m
//  victorious
//
//  Created by Sharif Ahmed on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTagSensitiveTextView.h"

#import "VTagStringFormatter.h"
#import "VTagDictionary.h"
#import "VTag.h"

@interface VTagSensitiveTextView ()

@property (nonatomic, strong) VTagDictionary *tagDictionary;

@end

@implementation VTagSensitiveTextView

#pragma mark - common inits

- (instancetype)init
{
    self = [super init];
    if ( self != nil )
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self != nil )
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if ( self != nil )
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recievedTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

#pragma mark - customization from content

- (void)setupWithDatabaseFormattedText:(NSString *)databaseFormattedText
                         tagAttributes:(NSDictionary *)tagAttributes
                     defaultAttributes:(NSDictionary *)defaultAttributes
                     andTagTapDelegate:(id<VTagSensitiveTextViewDelegate>)tagTapDelegate
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:databaseFormattedText attributes:defaultAttributes];
    self.tagStringAttributes = tagAttributes;
    self.tagDictionary = [VTagStringFormatter tagDictionaryFromFormattingAttributedString:attributedString
                                                                  withTagStringAttributes:tagAttributes
                                                               andDefaultStringAttributes:defaultAttributes];
    self.attributedText = attributedString;
    if ( tagTapDelegate != nil )
    {
        self.tagTapDelegate = tagTapDelegate;
    }
}

#pragma mark - Tap handling

- (void)recievedTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if ( self.tagStringAttributes == nil )
    {
        //Have nothing to do if we have no tag attributes to compare to
        return;
    }
    
    NSLayoutManager *layoutManager = self.layoutManager;
    CGPoint location = [tapGestureRecognizer locationInView:self];
    location.x -= self.textContainerInset.left;
    location.y -= self.textContainerInset.top;
    
    // Find the character that's been tapped on
    
    NSUInteger characterIndex;
    characterIndex = [layoutManager characterIndexForPoint:location
                                           inTextContainer:self.textContainer
                  fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < self.textStorage.length)
    {
        NSRange range;
        UIColor *foregroundColor = [self.attributedText attribute:NSForegroundColorAttributeName atIndex:characterIndex longestEffectiveRange:&range inRange:NSMakeRange(0, self.attributedText.length)];
        BOOL containsAttributes = [self.tagStringAttributes[NSForegroundColorAttributeName] isEqual:foregroundColor];
        
        if ( containsAttributes )
        {
            VTag *tag = [self.tagDictionary tagForKey:[self.attributedText.string substringWithRange:range]];
            if ( tag )
            {
                [self.tagTapDelegate tagSensitiveTextView:self tappedTag:tag];
            }
        }
    }
}

@end
