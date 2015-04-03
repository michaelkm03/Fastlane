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

+ (NSMutableDictionary *)sharedSizingCache
{
    static dispatch_once_t onceToken;
    static NSMutableDictionary *sizeCache;
    dispatch_once(&onceToken, ^{
        sizeCache = [[NSMutableDictionary alloc] init];
    });
    return sizeCache;
}

+ (void)clearCache
{
    [[self sharedSizingCache] removeAllObjects];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), kMinimumCellHeight);
}

+ (CGSize)actualSizeWithQuestion:(NSString *)quesiton
                      attributes:(NSDictionary *)attributes
                     maximumSize:(CGSize)maxSize
{
    NSString *keyForQuestionBoundsAndAttribute = [NSString stringWithFormat:@"%@, %@", quesiton, NSStringFromCGSize(maxSize)];
    
    NSValue *cachedValue = [[self sharedSizingCache] objectForKey:keyForQuestionBoundsAndAttribute];
    if (cachedValue != nil)
    {
        return [cachedValue CGSizeValue];
    }
    
    CGRect boundingRect = [quesiton boundingRectWithSize:CGSizeMake(maxSize.width - kLabelInset.left - kLabelInset.right, maxSize.height)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:attributes
                                                 context:[[NSStringDrawingContext alloc] init]];
    
    CGSize sizedPoll = CGSizeMake(maxSize.width, MAX(kMinimumCellHeight, CGRectGetHeight(boundingRect) + kLabelInset.top + kLabelInset.bottom));

    [[self sharedSizingCache] setObject:[NSValue valueWithCGSize:sizedPoll]
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
