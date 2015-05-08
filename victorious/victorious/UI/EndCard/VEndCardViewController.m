//
//  VEndCardViewController.m
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCardViewController.h"
#import "VEndCardBannerViewController.h"
#import "UIView+Autolayout.h"
#import "VDependencyManager.h"
#import "VVideoSettings.h"

static NSString * const kStoryboardName = @"EndCard";

@interface VEndCardViewController () <UICollectionViewDataSource, UICollectionViewDelegate, VEndCardBannerViewControllerDelegate>

@property (nonatomic, strong) VEndCardBannerViewController *nextVideoBannerViewController;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *nextVideoBannerViewBottomConstraint;
@property (nonatomic, assign) CGFloat nextVideoBannerViewBottomMax;

@property (nonatomic, weak, readwrite) IBOutlet UICollectionView *actionsCollectionView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *actionsCollectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *replayLabel;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) NSURL *nextVideoURL;

@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) VEndCardModel *model;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, assign) NSTimeInterval countdownDuration;
@property (nonatomic, strong) NSTimer *containerSizeChangeTimer;

@property (nonatomic, assign) CGFloat maxViewHeight;
@property (nonatomic, assign) CGFloat minViewHeight;

@property (nonatomic, weak) IBOutlet VVideoSettings *videoSettings;
@property (nonatomic, weak) IBOutlet VEndCardAnimator *animator;

@end

@implementation VEndCardViewController

+ (VEndCardViewController *)newWithDependencyManager:(VDependencyManager *)dependencyManager
                                               model:(VEndCardModel *)model
                                       minViewHeight:(CGFloat)minViewHeight
                                       maxViewHeight:(CGFloat)maxViewHeight
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardName bundle:nil];
    VEndCardViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    viewController.model = model;
    viewController.dependencyManager = dependencyManager;
    viewController.minViewHeight = minViewHeight;
    viewController.maxViewHeight = maxViewHeight;
    return viewController;
}

- (void)dealloc
{
    [self.containerSizeChangeTimer invalidate];
}

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nextVideoBannerViewBottomMax = self.nextVideoBannerViewBottomConstraint.constant;
    [self.nextVideoBannerViewController configureWithDependencyManager:self.dependencyManager];
    
    [self setupBackgroundView];
    self.animator.backgroundView = self.backgroundView;
    
    [self updateContainerSize:nil];
    
    [self.replayLabel setFont:[self.dependencyManager fontForKey:VDependencyManagerLabel3FontKey]];
    [self.replayLabel setText:self.model.videoTitle];
    
    NSString *identifier = [VEndCardActionCell cellIdentifier];
    [self.actionsCollectionView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellWithReuseIdentifier:identifier];
    
    self.actions = self.model.actions;
    
    self.nextVideoBannerViewController.delegate = self;
    
    [self configureWithModel:self.model];
    
    [self.animator reset];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.destinationViewController isKindOfClass:[VEndCardBannerViewController class]] )
    {
        self.nextVideoBannerViewController = (VEndCardBannerViewController *)segue.destinationViewController;
    }
}

- (void)handleRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat targetBottomSpaceConstant = UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 20.0f : self.nextVideoBannerViewBottomMax;
    self.nextVideoBannerViewBottomConstraint.constant = targetBottomSpaceConstant;
    [self.view layoutIfNeeded];
}

#pragma mark - Visual Effects

- (void)setupBackgroundView
{
    if ( self.backgroundView != nil )
    {
        return;
    }
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.backgroundView = blurEffectView;
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
    NSDictionary *views = @{ @"view" : self.backgroundView };
    NSDictionary *metrics = @{ @"height" : @( CGRectGetHeight(self.view.frame) ) };
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                      options:kNilOptions metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view(height)]"
                                                                      options:kNilOptions metrics:metrics views:views]];
}

#pragma mark - Configuration

- (void)configureWithModel:(VEndCardModel *)model
{
    [self.nextVideoBannerViewController configureWithModel:model];
    self.countdownDuration = model.countdownDuration;
}

- (void)setActions:(NSArray *)actions
{
    _actions = actions;
    [self.actionsCollectionView reloadData];
    CGFloat targetWidth = self.actions.count * [VEndCardActionCell minimumSize].width;
    self.actionsCollectionViewWidthConstraint.constant = targetWidth;
    [self.actionsCollectionView layoutIfNeeded];
}

#pragma mark - Public / Animation Controls

- (void)disableAutoplay
{
    [self.nextVideoBannerViewController stopCountdown];
}

- (void)transitionIn
{
    [self.view layoutIfNeeded];
    [self.nextVideoBannerViewController.view layoutIfNeeded];
    
    [self updateContainerSize:nil];
    
    [self.animator transitionInAllWithCompletion:^
     {
         if ( [self.videoSettings isAutoplayEnabled] )
         {
             [self.nextVideoBannerViewController startCountdownWithDuration:self.countdownDuration];
         }
         
         [self.nextVideoBannerViewController performSelector:@selector(showNextVideoDetails) withObject:nil afterDelay:2.0f];
         [self.containerSizeChangeTimer invalidate];
         self.containerSizeChangeTimer = [NSTimer timerWithTimeInterval:1.0f/60.0f
                                                                          target:self
                                                                        selector:@selector(updateContainerSize:)
                                                                        userInfo:nil
                                                                         repeats:YES];
         [[NSRunLoop mainRunLoop] addTimer:self.containerSizeChangeTimer forMode:NSRunLoopCommonModes];
     }];
}

- (void)transitionOutAllWithBackground:(BOOL)withBackground completion:(void(^)())completion
{
    [self updateContainerSize:nil];
    [self.containerSizeChangeTimer invalidate];
    
    [self disableAutoplay];
    
    [self.animator transitionOutAllWithBackground:withBackground completion:^void
     {
         [self.nextVideoBannerViewController resetNextVideoDetails];
         
         if ( completion != nil )
         {
             completion();
         }
     }];
}

#pragma mark - IBActions

- (IBAction)onReplay:(id)sender
{
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectReplayVideo];
    
    [self.delegate replaySelectedFromEndCard:self];
}

- (IBAction)onNextVideo:(id)sender
{
    [self nextVideoSelectedWithAutoPlay:NO];
}

#pragma mark - VEndCardViewControllerDelegate

- (void)nextVideoSelectedWithAutoPlay:(BOOL)autoPlay
{
    NSString *eventName = autoPlay ? VTrackingEventNextVideoDidAutoPlay : VTrackingEventUserDidSelectPlayNextVideo;
    [[VTrackingManager sharedInstance] trackEvent:eventName];
    
    [self.delegate nextSelectedFromEndCard:self];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.actions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VEndCardActionCell cellIdentifier];
    VEndCardActionCell *cell = (VEndCardActionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    VEndCardActionModel *actionModel = self.actions[ indexPath.row ];
    [cell setModel:actionModel];
    [cell setFont:[self.dependencyManager fontForKey:VDependencyManagerLabel2FontKey]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize minumumSize = [VEndCardActionCell minimumSize];
    NSUInteger numCells = [self collectionView:collectionView numberOfItemsInSection:indexPath.section];
    CGFloat targetWidth = CGRectGetWidth(collectionView.frame) / numCells;
    return CGSizeMake( MAX(targetWidth, minumumSize.width), CGRectGetHeight(collectionView.frame) );
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self disableAutoplay];
    VEndCardActionCell *actionCell = (VEndCardActionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ( actionCell.enabled )
    {
        [self.delegate actionCellSelected:actionCell atIndex:indexPath.row];
    }
}

#pragma mark - Content size animation

- (void)updateContainerSize:(id)sender
{
    const CGFloat expandedRatio = (CGRectGetHeight(self.view.frame) - self.minViewHeight) / (self.maxViewHeight - self.minViewHeight);
    if ( expandedRatio < 1.0 )
    {
        [self disableAutoplay];
    }
    
    self.animator.expandedRatio = expandedRatio;
}

@end
