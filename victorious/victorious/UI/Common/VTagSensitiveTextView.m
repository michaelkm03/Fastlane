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

@import CCHLinkTextView;

@interface VTagSensitiveTextView () <UIGestureRecognizerDelegate>

@property (nonatomic, readwrite) VTagDictionary *tagDictionary;
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

- (void)zeroInsets
{
    self.textContainerInset = UIEdgeInsetsZero;
    self.textContainer.lineFragmentPadding = 0.0f;
    self.contentInset = UIEdgeInsetsZero;
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
    [VTagSensitiveTextView displayFormattedStringFromDatabaseFormattedText:databaseFormattedText
                                                             tagAttributes:tagAttributes
                                                      andDefaultAttributes:defaultAttributes
                                                           toCallbackBlock:^(VTagDictionary *foundTags, NSAttributedString *displayFormattedString)
     {
         self.tagDictionary = foundTags;
         self.tagStringAttributes = tagAttributes;
         self.attributedText = displayFormattedString;
         if ( tagTapDelegate != nil )
         {
             self.tagTapDelegate = tagTapDelegate;
         }
     }];
}

+ (void)displayFormattedStringFromDatabaseFormattedText:(NSString *)databaseFormattedText
                                          tagAttributes:(NSDictionary *)tagAttributes
                                   andDefaultAttributes:(NSDictionary *)defaultAttributes
                                        toCallbackBlock:(void (^)(VTagDictionary *foundTags, NSAttributedString *displayFormattedString))completionBlock
{
    NSAssert(tagAttributes != nil, @"tagAttributes must be non-nil");
    NSAssert(defaultAttributes != nil, @"defaultAttributes must be non-nil");
    NSAssert(completionBlock != nil, @"completionBlock must be non-nil");
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:databaseFormattedText != nil ? databaseFormattedText : @"" attributes:defaultAttributes];
    VTagDictionary *foundTags = [VTagStringFormatter tagDictionaryFromFormattingAttributedString:attributedString
                                                                         withTagStringAttributes:tagAttributes
                                                                      andDefaultStringAttributes:defaultAttributes];
    completionBlock(foundTags, attributedString);
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
    [self tagAtLocation:location withCallbackBlock:^(VTag *tag, NSRange range)
    {
        if ( tag != nil )
        {
            self.highlightRange = range;
            self.selectedTag = tag;
            UIColor *highlightColor = [[tag.tagStringAttributes objectForKey:NSForegroundColorAttributeName] colorWithAlphaComponent:0.5f];
            [self.textStorage addAttribute:NSForegroundColorAttributeName value:highlightColor range:self.highlightRange];
        }
    }];
}

- (void)didTapAtLocation:(CGPoint)location
{
    if ( self.selectedTag != nil && self.tagTapDelegate != nil )
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

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL pointInside = [super pointInside:point withEvent:event];

    if ( !pointInside )
    {
        return NO;
    }
    
    __block VTag *foundTag = nil;
    [self tagAtLocation:point withCallbackBlock:^(VTag *tag, NSRange range)
    {
        foundTag = tag;
    }];
    return foundTag != nil;
}

- (void)tagAtLocation:(CGPoint)location withCallbackBlock:(void (^)(VTag *tag, NSRange range))callbackBlock
{
    NSParameterAssert(callbackBlock != nil);
    
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
        UIColor *foregroundColor = [self.textStorage attribute:NSForegroundColorAttributeName atIndex:characterIndex longestEffectiveRange:&range inRange:NSMakeRange(0, self.textStorage.length)];
        BOOL containsAttributes = [self.tagStringAttributes[NSForegroundColorAttributeName] isEqual:foregroundColor];
        
        if ( containsAttributes )
        {
            VTag *tag =  [self.tagDictionary tagForKey:[self.textStorage.string substringWithRange:range]];
            callbackBlock(tag, range);
            return;
        }
    }
    callbackBlock(nil, NSMakeRange(NSNotFound, 0));
}

@end
