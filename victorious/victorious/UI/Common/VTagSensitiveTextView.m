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
#import <CCHLinkGestureRecognizer.h>

@interface VTagSensitiveTextView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) VTagDictionary *tagDictionary;
@property (nonatomic, assign) CGPoint touchDownLocation;
@property (nonatomic, assign) NSRange highlightRange;
@property (nonatomic, strong) VTag *selectedTag;
@property (nonatomic, readwrite) NSDictionary *tagStringAttributes;

@end

@implementation VTagSensitiveTextView

#pragma mark - common inits

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
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
    CCHLinkGestureRecognizer *linkGestureRecognizer = [[CCHLinkGestureRecognizer alloc] initWithTarget:self action:@selector(linkAction:)];
    linkGestureRecognizer.delegate = self;
    [self addGestureRecognizer:linkGestureRecognizer];
}

#pragma mark - customization from content

- (void)setupWithDatabaseFormattedText:(NSString *)databaseFormattedText
                         tagAttributes:(NSDictionary *)tagAttributes
                     defaultAttributes:(NSDictionary *)defaultAttributes
                     andTagTapDelegate:(id<VTagSensitiveTextViewDelegate>)tagTapDelegate
{
    NSAssert(tagAttributes != nil, @"tagAttributes must be non-nil");
    NSAssert(defaultAttributes != nil, @"defaultAttributes must be non-nil");
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:databaseFormattedText != nil ? databaseFormattedText : @"" attributes:defaultAttributes];
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

#pragma mark - Touch handling

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)linkAction:(CCHLinkGestureRecognizer *)recognizer
{
    if ( recognizer.state == UIGestureRecognizerStateBegan )
    {
        NSAssert(CGPointEqualToPoint(self.touchDownLocation, CGPointZero), @"Invalid touch down location");
        
        CGPoint location = [recognizer locationInView:self];
        self.touchDownLocation = location;
        [self didTouchDownAtLocation:location];
    }
    else if ( recognizer.state == UIGestureRecognizerStateEnded )
    {
        NSAssert(!CGPointEqualToPoint(self.touchDownLocation, CGPointZero), @"Invalid touch down location");
        
        CGPoint location = self.touchDownLocation;
        if ( recognizer.result == CCHLinkGestureRecognizerResultTap )
        {
            [self didTapAtLocation:location];
        }
        
        [self didCancelTouchDownAtLocation:location];
        self.touchDownLocation = CGPointZero;
    }
}

- (void)didTouchDownAtLocation:(CGPoint)location
{
    //Highlight region here
    location.x -= self.textContainerInset.left;
    location.y -= self.textContainerInset.top;
    
    // Find the character that's been tapped on
    NSUInteger characterIndex;
    characterIndex = [self.layoutManager characterIndexForPoint:location
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
                self.highlightRange = range;
                self.selectedTag = tag;
                UIColor *highlightColor = [[tag.tagStringAttributes objectForKey:NSForegroundColorAttributeName] colorWithAlphaComponent:0.5f];
                [self.textStorage addAttribute:NSForegroundColorAttributeName value:highlightColor range:self.highlightRange];
            }
        }
    }
}

- (void)didTapAtLocation:(CGPoint)location
{
    if ( self.selectedTag != nil )
    {
        [self.tagTapDelegate tagSensitiveTextView:self tappedTag:self.selectedTag];
    }
}

- (void)didCancelTouchDownAtLocation:(CGPoint)location
{
    if ( self.selectedTag != nil )
    {
        [self.textStorage setAttributes:self.selectedTag.tagStringAttributes range:self.highlightRange];
        self.selectedTag = nil;
    }

}

@end
