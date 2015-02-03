//
//  VEndCardViewController.m
//  AutoplayNext
//
//  Created by Patrick Lynch on 1/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEndCardViewController.h"
#import "VEndCardBannerViewController.h"
#import "UIVIew+AutoLayout.h"
#import "VDependencyManager.h"

static const BOOL kForceIOS7 = NO;
static NSString * const kStoryboardName = @"EndCard";

@interface VEndCardViewController () <UICollectionViewDataSource, UICollectionViewDelegate, VEndCardBannerViewController>

@property (nonatomic, strong) VEndCardBannerViewController *nextVideoBannerViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextVideoBannerViewBottomConstraint;
@property (nonatomic, assign) CGFloat nextVideoBannerViewBottomMax;

@property (weak, nonatomic, readwrite) IBOutlet UICollectionView *actionsCollectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionsCollectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *replayButton;
@property (strong, nonatomic) UIView *backgroundView;
@property (nonatomic, strong) NSURL *nextVideoURL;

@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) VEndCardModel *model;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, assign) NSTimeInterval countdownDuration;
@property (nonatomic, strong) NSTimer *containerSizeChangeTimer;

@property (nonatomic, assign) CGFloat maxViewHeight;
@property (nonatomic, assign) CGFloat minViewHeight;

@property (weak, nonatomic) IBOutlet VEndCardAnimator *animator;

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
    
    [self setupBackgroundView];
    self.animator.backgroundView = self.backgroundView;
    
    [self updateContainerSize:nil];
    
    [self.replayButton setTitle:self.model.videoTitle forState:UIControlStateNormal];
    
    NSString *identifier = [VEndCardActionCell cellIdentifier];
    [self.actionsCollectionView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellWithReuseIdentifier:identifier];
    
    self.actions = [self.dependencyManager arrayForKey:@"actions"];
    
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
    
    if ( NSClassFromString( @"UIBlurEffect" ) != nil && !kForceIOS7 )
    {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.backgroundView = blurEffectView;
    }
    else
    {
        UIView *overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
        self.backgroundView = overlayView;
    }
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

#pragma mark - Public Animation Controls

- (void)transitionIn
{
    [self.view layoutIfNeeded];
    [self.nextVideoBannerViewController.view layoutIfNeeded];
    
    [self updateContainerSize:nil];
    
    [self.animator transitionInAllWithCompletion:^
     {
         [self.nextVideoBannerViewController startCountdownWithDuration:self.countdownDuration];
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
    
    [self.nextVideoBannerViewController stopCountdown];
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
    [self.delegate replaySelectedFromEndCard:self];
}

- (IBAction)onNextVideo:(id)sender
{
    [self nextVideoSelected];
}

#pragma mark - VEndCardViewControllerDelegate

- (void)nextVideoSelected
{
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
    NSDictionary *action = self.actions[ indexPath.row ];
    [cell setImage:[UIImage imageNamed:action[ @"image_name" ]]];
    [cell setTitle:action[ @"name" ]];
    [cell setSuccessImage:action[ @"success_image_name" ]];
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
    [self.nextVideoBannerViewController stopCountdown];
    VEndCardActionCell *actionCell = (VEndCardActionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ( actionCell.enabled )
    {
        [self.delegate actionCell:actionCell selectedWithIndex:indexPath.row];
    }
}

#pragma mark - Content size animation

- (void)updateContainerSize:(id)sender
{
    const CGFloat expandedRatio = (CGRectGetHeight(self.view.frame) - self.minViewHeight) / (self.maxViewHeight - self.minViewHeight);
    if ( expandedRatio < 1.0 )
    {
        [self.nextVideoBannerViewController stopCountdown];
    }
    
    self.animator.expandedRatio = expandedRatio;
}

@end
