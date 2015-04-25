//
//  VContentPollQuestionCell.m
//  victorious
//
//  Created by Michael Sena on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentPollQuestionCell.h"

#if CGFLOAT_IS_DOUBLE
#define roundCGFloat(x) round(x)
#define floorCGFloat(x) floor(x)
#define ceilCGFloat(x) ceil(x)
#else
#define roundCGFloat(x) roundf(x)
#define floorCGFloat(x) floor(x)
#define ceilCGFloat(x) ceil(x)
#endif

static CGFloat const kMinimumCellHeight = 90.0f;
static UIEdgeInsets kLabelInset = { 8, 8, 8, 8};

@interface VContentPollQuestionCell ()

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

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
    
    CGSize sizedPoll = CGSizeMake(maxSize.width, MAX(kMinimumCellHeight, ceilCGFloat(CGRectGetHeight(boundingRect)) + kLabelInset.top + kLabelInset.bottom));

    [[self sizingCache] setObject:[NSValue valueWithCGSize:sizedPoll]
                           forKey:keyForQuestionBoundsAndAttribute];
    return sizedPoll;
}

- (void)setQuestion:(NSAttributedString *)question
{
    _question = [question copy];
    self.questionLabel.attributedText = _question;
}

@end
