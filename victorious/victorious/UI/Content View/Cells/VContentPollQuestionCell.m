//
//  VContentPollQuestionCell.m
//  victorious
//
//  Created by Michael Sena on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentPollQuestionCell.h"

#import "VThemeManager.h"

static CGFloat const kMinimumCellHeight = 90.0f;
static UIEdgeInsets kLabelInset = { 8, 8, 8, 8};

@interface VContentPollQuestionCell ()

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@end

@implementation VContentPollQuestionCell

static NSMutableDictionary *sizeCache;

+ (NSMutableDictionary *)sizingCache
{
    if (sizeCache == nil)
    {
        sizeCache = [[NSMutableDictionary alloc] init];
    }
    return sizeCache;
}

+ (void)clearCache
{
    sizeCache = nil;
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
    
    CGSize sizedPoll = CGSizeMake(maxSize.width, MAX(kMinimumCellHeight, CGRectGetHeight(boundingRect) + kLabelInset.top + kLabelInset.bottom));

    [[self sizingCache] setObject:[NSValue valueWithCGSize:sizedPoll]
                           forKey:keyForQuestionBoundsAndAttribute];
    return sizedPoll;
}

- (void)dealloc
{
    [[self class] clearCache];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.questionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
}

- (void)setQuestion:(NSAttributedString *)question
{
    _question = [question copy];
    self.questionLabel.attributedText = _question;
}

@end
