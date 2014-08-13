//
//  VEmotiveBallisticsViewController.m
//  victorious
//
//  Created by Will Long on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnalyticsRecorder.h"
#import "VEmotiveBallisticsBarViewController.h"
#import "VLargeNumberFormatter.h"

#import "VConstants.h"
#import "VObjectManager+Sequence.h"
#import "VLoginViewController.h"

#import "VThemeManager.h"

#import "VVoteResult.h"
#import "VVoteType+Fetcher.h"
#import "VSequence+Fetcher.h"

#import "VSequence.h"

@interface VEmotiveBallisticsBarViewController ()

@property (strong, nonatomic) VVoteType* likeVote;
@property (strong, nonatomic) VVoteType* dislikeVote;
@property (strong, nonatomic) NSMutableDictionary* voteCounts; ///< Holds the new votes that have been cast by the user
@property (strong, nonatomic) NSMutableDictionary* voteCountsForDisplay; ///< Holds the total of this user's votes and remote users' votes
@property (strong, nonatomic) VLargeNumberFormatter *largeNumberFormatter;

@end

@implementation VEmotiveBallisticsBarViewController

+ (instancetype)sharedInstance
{
    static  VEmotiveBallisticsBarViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VEmotiveBallisticsBarViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kEmotiveBallisticsBarStoryboardID];
    });
    
    return sharedInstance;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.dislikeVote = [VVoteType dislikeVote];
    self.likeVote = [VVoteType likeVote];
    
    self.voteCounts = [[NSMutableDictionary alloc] init];
    self.voteCountsForDisplay = [[NSMutableDictionary alloc] init];
    
    self.largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIPanGestureRecognizer *postivePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    // Setting the swipe direction.
    [self.leftButton addGestureRecognizer:postivePanGesture];
    
    UIPanGestureRecognizer *negativePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.rightButton addGestureRecognizer:negativePanGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateVoteCountDisplay];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSArray* voteTypes = [self.voteCounts allKeys];
    if ([voteTypes count])
    {
        NSArray* voteCounts = [self.voteCounts objectsForKeys:voteTypes notFoundMarker:[NSNull null]];
        
        __block NSManagedObjectContext* context = nil;
        [self.voteCounts enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            NSPredicate* sortPredicate = [NSPredicate predicateWithFormat:@"remoteId == %d", ((NSNumber*)key).integerValue];
            
            VVoteResult* vote = (VVoteResult*)[[self.sequence.voteResults filteredSetUsingPredicate:sortPredicate] anyObject];
            vote.count = @(vote.count.integerValue + ((NSNumber*)obj).integerValue);
            context = vote.managedObjectContext;
        }];
        [context saveToPersistentStore:nil];
        
        [[VObjectManager sharedManager] voteSequence:self.sequence
                                           voteTypes:voteTypes
                                          votecounts:voteCounts
                                        successBlock:nil
                                           failBlock:nil];
        
        [self.voteCounts removeAllObjects];
    }
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    if (!sequence)
        return;
    
    self.voteCountsForDisplay[self.likeVote.remoteId] = [self.sequence voteCountForVoteID:self.likeVote.remoteId];
    self.voteCountsForDisplay[self.dislikeVote.remoteId] = [self.sequence voteCountForVoteID:self.dislikeVote.remoteId];
    
    if ([self isViewLoaded])
    {
        [self updateVoteCountDisplay];
    }
}

- (void)updateVoteCountDisplay
{
    NSInteger likeVotes = [self.voteCountsForDisplay[self.likeVote.remoteId] integerValue];
    NSInteger dislikeVotes = [self.voteCountsForDisplay[self.dislikeVote.remoteId] integerValue];
    
    self.leftLabel.text = [self.largeNumberFormatter stringForInteger:likeVotes];
    self.rightLabel.text = [self.largeNumberFormatter stringForInteger:dislikeVotes];
}

#pragma mark - Actions
- (IBAction)pressedPostiveEmotive:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryInteraction action:@"Positive Emotive" label:self.sequence.name value:nil];
    
    CGFloat x = self.target.center.x + ([self randomFloat] * self.target.frame.size.width / 4);
    CGFloat y = self.target.center.y + ([self randomFloat] * self.target.frame.size.height / 4);
    
    [self throwEmotive:self.leftButton toPoint:CGPointMake(x, y)];
}

- (IBAction)pressedNegativeEmotive:(id)sender
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    [[VAnalyticsRecorder sharedAnalyticsRecorder] sendEventWithCategory:kVAnalyticsEventCategoryInteraction action:@"Negative Emotive" label:self.sequence.name value:nil];
    
    CGFloat x = self.target.center.x + ([self randomFloat] * self.target.frame.size.width / 4);
    CGFloat y = self.target.center.y + ([self randomFloat] * self.target.frame.size.height / 4);
    
    [self throwEmotive:self.rightButton toPoint:CGPointMake(x, y)];
}

- (void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    if (![VObjectManager sharedManager].mainUser)
    {
        [self presentViewController:[VLoginViewController loginViewController] animated:YES completion:NULL];
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        //In points / second
        CGPoint lastPosition = [recognizer locationInView:self.target];
        
        lastPosition.x = fminf(lastPosition.x, self.target.center.x + (self.target.frame.size.width / 4));
        lastPosition.x = fmaxf(lastPosition.x, self.target.center.x - (self.target.frame.size.width / 4));
        lastPosition.y = fminf(lastPosition.y, self.target.center.y + (self.target.frame.size.height / 4));
        lastPosition.y = fmaxf(lastPosition.y, self.target.center.y - (self.target.frame.size.height / 4));

        [self throwEmotive:(UIButton*)recognizer.view toPoint:lastPosition];
    }
}

- (void)throwEmotive:(UIButton*)emotive toPoint:(CGPoint)point
{
    
    if (emotive == self.leftButton)
    {
        NSInteger voteCount = [self.voteCountsForDisplay[self.likeVote.remoteId] integerValue] + 1;
        self.voteCountsForDisplay[self.likeVote.remoteId] = @(voteCount);
        [self updateVoteCountDisplay];
        
        NSNumber* currentCount = [self.voteCounts objectForKey:self.likeVote.remoteId.stringValue];
        currentCount = @(currentCount.integerValue + 1);
        [self.voteCounts setObject:currentCount forKey:self.likeVote.remoteId.stringValue];
    }
    else if (emotive == self.rightButton)
    {
        NSInteger voteCount = [self.voteCountsForDisplay[self.dislikeVote.remoteId] integerValue] + 1;
        self.voteCountsForDisplay[self.dislikeVote.remoteId] = @(voteCount);
        [self updateVoteCountDisplay];
        
        NSNumber* currentCount = [self.voteCounts objectForKey:self.dislikeVote.remoteId.stringValue];
        currentCount = @(currentCount.integerValue + 1);
        [self.voteCounts setObject:currentCount forKey:self.dislikeVote.remoteId.stringValue];
    }
    
    UIView *thrownImageSuperview = self.parentViewController.view ?: self.view;
    
    point = [self.target convertPoint:point toView:thrownImageSuperview];
    __block UIImageView* thrownImage = [[UIImageView alloc] initWithImage:emotive.imageView.image];
    thrownImage.frame = CGRectMake(0, 0, 110, 110);
    thrownImage.center = [emotive.superview convertPoint:emotive.center toView:thrownImageSuperview];
    
    NSMutableArray* emotiveAnimations = [[NSMutableArray alloc] initWithCapacity:13];
    for (int i = 0; i < 17; i++)
    {
        UIImage* nextImage;
        if (emotive == self.leftButton && i<13)
            nextImage = [UIImage imageNamed:[@"Heart" stringByAppendingString:@(i).stringValue]];
        
        else if (emotive == self.rightButton)
            nextImage = [UIImage imageNamed:[@"Tomato" stringByAppendingString:@(i).stringValue]];
        
        if (nextImage)
            [emotiveAnimations addObject:nextImage];
    }
    
    thrownImage.animationImages = emotiveAnimations;
    thrownImage.animationDuration = .25f;
    thrownImage.animationRepeatCount = 1;
    
    thrownImage.contentMode = UIViewContentModeScaleAspectFit;
    
    [thrownImageSuperview addSubview:thrownImage];
    [UIView animateWithDuration:.3f
                     animations:^
     {
         thrownImage.center = point;
     }
                     completion:^(BOOL finished)
     {
         thrownImage.image = [thrownImage.animationImages lastObject];
         [thrownImage startAnimating];
         [self performSelector:@selector(removeThrownImage:) withObject:thrownImage afterDelay:thrownImage.animationDuration];
     }];
}

- (void)removeThrownImage:(UIImageView*)thrownImage
{
    [thrownImage removeFromSuperview];
}

- (float)randomFloat
{
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * 2) -1;
}


@end
