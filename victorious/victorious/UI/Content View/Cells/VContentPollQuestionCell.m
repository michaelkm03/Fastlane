//
//  VContentPollQuestionCell.m
//  victorious
//
//  Created by Michael Sena on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentPollQuestionCell.h"
#import "VScrollingTextContainerView.h"

@interface VContentPollQuestionCell ()

@property (weak, nonatomic) IBOutlet VScrollingTextContainerView *scrollingTextContainerView;

@end

@implementation VContentPollQuestionCell

+ (NSCache *)sizingCache
{
    static NSCache *_sizeCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _sizeCache = [[NSCache alloc] init];
    });
    return _sizeCache;
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), kMinimumCellHeight);
}

+ (CGSize)actualSizeWithQuestion:(NSString *)question
                      attributes:(NSDictionary *)attributes
                     maximumSize:(CGSize)maxSize
{
    NSString *keyForQuestionBoundsAndAttribute = [NSString stringWithFormat:@"%@, %@", question, NSStringFromCGSize(maxSize)];
    
    NSValue *cachedValue = [[self sizingCache] objectForKey:keyForQuestionBoundsAndAttribute];
    if (cachedValue != nil)
    {
        return [cachedValue CGSizeValue];
    }
    
    CGRect boundingRect = [question boundingRectWithSize:CGSizeMake(maxSize.width - kLabelInset.left - kLabelInset.right, maxSize.height)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:attributes
                                                 context:[[NSStringDrawingContext alloc] init]];
    CGFloat minHeight = MIN(kMaximumCellHeight, VCEIL((CGRectGetHeight(boundingRect))) + kLabelInset.top + kLabelInset.bottom);
    CGSize sizedPoll = CGSizeMake(maxSize.width, MAX(kMinimumCellHeight, minHeight));

    [[self sizingCache] setObject:[NSValue valueWithCGSize:sizedPoll]
                           forKey:keyForQuestionBoundsAndAttribute];
    return sizedPoll;
}

- (void)setQuestion:(NSAttributedString *)question
{
    _question = [question copy];
    self.scrollingTextContainerView.text = question;
    
    [self.scrollingTextContainerView setGradient:0.2
                                       direction:VGradientTypeVertical
                                          colors:@[
                                                   [UIColor clearColor],
                                                   [UIColor blackColor],
                                                   [UIColor blackColor],
                                                   [UIColor clearColor]
                                                   ]];
    [self.scrollingTextContainerView startScrollWithScrollSpeed:10];
}

@end
