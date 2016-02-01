//
//  VContentPollQuestionCell.m
//  victorious
//
//  Created by Michael Sena on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentPollQuestionCell.h"

static CGFloat const kMinimumCellHeight = 90.0f;
static CGFloat const kMaximumCellHeight = 120.0f;
static CGFloat const kScrollBoundary = 20.0f;
static UIEdgeInsets kLabelInset = { 8, 8, 8, 8};

@interface VContentPollQuestionCell ()

@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL scrollDown;

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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startScroll];
}

- (void)awakeFromNib
{
    self.questionTextView.delegate = self;
}

- (void)setGradient
{
    UIColor *backgroundColor = [UIColor darkGrayColor];
    UIColor *zeroAlphaBackgroundColor = [backgroundColor colorWithAlphaComponent:0.0];
    
    CGSize size = self.bounds.size;
    CGFloat gradientHeight = size.height/4;
    
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    topGradient.frame = CGRectMake(0, 0, size.width, gradientHeight);
    topGradient.colors = [NSArray arrayWithObjects:(id)[backgroundColor CGColor], (id)[zeroAlphaBackgroundColor CGColor], nil];
    
    CAGradientLayer *bottomGradient = [CAGradientLayer layer];
    bottomGradient.frame = CGRectMake(0, size.height - gradientHeight, size.width, gradientHeight);
    bottomGradient.colors = [NSArray arrayWithObjects:(id)[zeroAlphaBackgroundColor CGColor], (id)[backgroundColor CGColor], nil];
    
    [self.layer addSublayer:topGradient];
    [self.layer addSublayer:bottomGradient];
}

- (void)stopScroll
{
    [self.timer invalidate];
}

- (void)startScroll
{
    if (self.timer)
    {
        [self.timer invalidate];
    }
    if (self.questionTextView.contentSize.height > kMaximumCellHeight)
    {
        self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(autoscrollTimerFired) userInfo:nil repeats:YES];
        self.scrollDown = YES;
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)autoscrollTimerFired
{
    CGFloat yOffset = self.questionTextView.contentOffset.y;
    if (self.scrollDown)
    {
        yOffset += 2;
        CGFloat maxOffset = self.questionTextView.contentSize.height - self.questionTextView.bounds.size.height + kScrollBoundary;
        if (yOffset > maxOffset)
        {
            yOffset = maxOffset;
            self.scrollDown = NO;
        }
    }
    else
    {
        yOffset -= 10;
        if (yOffset < -kScrollBoundary)
        {
            yOffset = -kScrollBoundary;
            self.scrollDown = YES;
        }
    }
    
    [self.questionTextView setContentOffset:CGPointMake(0, yOffset) animated:YES];
    
}

- (void)setQuestion:(NSAttributedString *)question
{
    _question = [question copy];
    self.questionTextView.attributedText = _question;
    self.questionTextView.textAlignment = NSTextAlignmentCenter;
//    self.questionLabel.attributedText = _question;
}

@end
