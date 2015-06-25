//
//  VPublishViewController.m
//  victorious
//
//  Created by Michael Sena on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPublishViewController.h"
#import "UIView+VDynamicsHelpers.h"
#import "VDependencyManager.h"

#import "VPlaceholderTextView.h"
#import "VContentInputAccessoryView.h"

#import "VObjectManager+ContentCreation.h"
#import "VPublishParameters.h"

#import "UIAlertView+VBlocks.h"

#import <MBProgressHUD/MBProgressHUD.h>

#import "NSURL+MediaType.h"

#import "VPublishSaveCollectionViewCell.h"
#import "VPublishShareCollectionViewCell.h"
#import "VShareItemCollectionViewCell.h"
#import "VShareMenuItem.h"
#import "VDependencyManager+VShareMenuItem.h"
#import "VFacebookManager.h"
#import "VTwitterManager.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VKeyboardStyle.h"

@import AssetsLibrary;

static const CGFloat kTriggerVelocity = 500.0f;
static const CGFloat kSnapDampingConstant = 0.9f;
static const CGFloat kTopSpacePublishPrompt = 50.0f;
static const CGFloat kAccessoryViewHeight = 44.0f;
static const CGFloat kCollectionViewVerticalSpace = 8.0f;
static const UIEdgeInsets kCollectionViewEdgeInsets = { 8.0f, 9.0f, 8.0f, 9.0f };
static NSUInteger const kMaxCaptionLength = 120;
static NSString * const kBackButtonTitleKey = @"backButtonText";
static NSString * const kPlaceholderTextKey = @"placeholderText";
static NSString * const kShareContainerBackgroundColor = @"color.shareContainer";
static NSString * const kCaptionContainerBackgroundColor = @"color.captionContainer";
static NSString * const kKeyboardStyleKey = @"keyboardStyle";

@interface VPublishViewController () <UICollisionBehaviorDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, VContentInputAccessoryViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, VPublishShareCollectionViewCellDelegate, VBackgroundContainer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UIView *publishPrompt;
@property (nonatomic, weak) IBOutlet UIView *captionContainer;
@property (nonatomic, weak) IBOutlet UIImageView *captionSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet VPlaceholderTextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) VPublishSaveCollectionViewCell *saveContentCell;
@property (nonatomic, strong) VPublishShareCollectionViewCell *shareContentCell;
@property (nonatomic, assign) BOOL hasShareCell;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *cardHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *previewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *dividerLineHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *publishButtonHeightConstraint;
@property (nonatomic, assign) CGFloat cellWidth;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UISnapBehavior *snapBehavior;
@property (nonatomic, copy, readwrite) void (^animateInBlock)(void);

@property (nonatomic, assign) BOOL publishing;

@end

@implementation VPublishViewController

#pragma mark - VHasManagedDependencies

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VPublishViewController *publishViewController = [[VPublishViewController alloc] initWithNibName:NSStringFromClass([VPublishViewController class])
                                                                                             bundle:nil];
    publishViewController.dependencyManager = dependencyManager;
    return publishViewController;
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCollectionView];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    self.publishButton.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self.publishButton setTitleColor:[self.dependencyManager colorForKey:VDependencyManagerSecondaryLinkColorKey]
                             forState:UIControlStateNormal];
    [self.publishButton.titleLabel setFont:[self.dependencyManager fontForKey:VDependencyManagerButton1FontKey]];
    
    __weak typeof(self) welf = self;
    
    NSUInteger random = arc4random_uniform(100);
    CGFloat randomFloat = random / 100.0f;
    CGAffineTransform initialTransformTranslation = CGAffineTransformMakeTranslation(0, -CGRectGetMidY(self.view.frame));
    CGAffineTransform initialTransformRotation = CGAffineTransformMakeRotation(M_PI * (1-randomFloat));
    self.publishPrompt.transform = CGAffineTransformConcat(initialTransformTranslation, initialTransformRotation);
    self.animateInBlock = ^void(void)
    {
        welf.publishPrompt.transform = CGAffineTransformIdentity;
    };
    
    [self setupCaptionTextView];
    
    self.captionSeparator.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    UIFont *cancelButtonFont = [self.dependencyManager fontForKey:VDependencyManagerButton2FontKey];
    if (cancelButtonFont != nil)
    {
        attributes[NSFontAttributeName] = cancelButtonFont;
    }
    NSString *cancelButtonText = [self.dependencyManager stringForKey:kBackButtonTitleKey];
    self.cancelButton.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(cancelButtonText, @"")
                                                                                  attributes:attributes];
    UIColor *textColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey];
    [self.cancelButton setTitleColor:textColor ?: [UIColor whiteColor]
                            forState:UIControlStateNormal];
    
    self.previewImageView.image = self.publishParameters.previewImage;
    
    [self setupShareCard];
}

- (void)setupCaptionTextView
{
    self.captionContainer.backgroundColor = [self.dependencyManager colorForKey:kCaptionContainerBackgroundColor];
    
    VContentInputAccessoryView *inputAccessoryView = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kAccessoryViewHeight)];
    inputAccessoryView.textInputView = self.captionTextView;
    inputAccessoryView.maxCharacterLength = kMaxCaptionLength;
    inputAccessoryView.delegate = self;
    inputAccessoryView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    self.captionTextView.keyboardAppearance = [self.dependencyManager keyboardStyleForKey:kKeyboardStyleKey];
    self.captionTextView.backgroundColor = [UIColor clearColor];
    self.captionTextView.inputAccessoryView = inputAccessoryView;
    self.captionTextView.textContainerInset = UIEdgeInsetsZero;
    [self.captionTextView setPlaceholderTextColor:[self.dependencyManager colorForKey:VDependencyManagerPlaceholderTextColorKey]];
    self.captionTextView.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.captionTextView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
    NSString *placeholderText = [self.dependencyManager stringForKey:kPlaceholderTextKey];
    self.captionTextView.placeholderText = NSLocalizedString(placeholderText, @"Caption entry placeholder text");
    UIFont *font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    if ( font != nil )
    {
        self.captionTextView.typingAttributes = @{NSFontAttributeName: font};
        self.captionTextView.font = font;
    }
    UIFont *placeholderFont = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    if ( placeholderFont != nil )
    {
        [self.captionTextView setPlaceholderFont:placeholderFont];
    }
}

- (void)setupCollectionView
{
    self.collectionView.scrollEnabled = NO;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [self.dependencyManager colorForKey:kShareContainerBackgroundColor];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.sectionInset = kCollectionViewEdgeInsets;
    flowLayout.minimumLineSpacing = kCollectionViewVerticalSpace;
    
    [self.collectionView registerNib:[VPublishSaveCollectionViewCell nibForCell] forCellWithReuseIdentifier:[VPublishSaveCollectionViewCell suggestedReuseIdentifier]];
    [self.collectionView registerNib:[VPublishShareCollectionViewCell nibForCell] forCellWithReuseIdentifier:[VPublishShareCollectionViewCell suggestedReuseIdentifier]];
    
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    width -= contentInset.right + contentInset.left;
    UIEdgeInsets sectionInset = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).sectionInset;
    width -= sectionInset.right + sectionInset.left;
    self.cellWidth = width;
}

- (void)setupShareCard
{
    self.hasShareCell = [self.dependencyManager shareMenuItems].count != 0;
    
    CGFloat staticHeights = self.publishButtonHeightConstraint.constant + self.previewHeightConstraint.constant + self.dividerLineHeightConstraint.constant;
    CGFloat shareHeight = [VPublishShareCollectionViewCell desiredHeightForDependencyManager:self.dependencyManager];
    CGSize shareSize = CGSizeMake(self.cellWidth, shareHeight);
    if ( shareSize.height != 0 )
    {
        shareSize.height += kCollectionViewVerticalSpace;
    }
    CGFloat collectionViewHeight = [VPublishSaveCollectionViewCell desiredHeight] + shareSize.height + kCollectionViewVerticalSpace * 2;
    self.cardHeightConstraint.constant = staticHeights + collectionViewHeight;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*
     Setup behaviors in view did appear instead of viewDidLayoutSubviews to avoid issues with
        restoring the rotation of the prompt (managed by the animateInBlock)
     */
    [self setupBehaviors];
}

#pragma mark - Property Accessors

- (void)setPublishParameters:(VPublishParameters *)publishParameters
{
    _publishParameters = publishParameters;
    
    self.previewImageView.image = publishParameters.previewImage;
}

#pragma mark - Target/Action

- (IBAction)publish:(id)sender
{
    [self.captionTextView resignFirstResponder];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view
                                              animated:YES];
    hud.dimBackground = YES;
    hud.labelText = NSLocalizedString(@"Publishing...", @"Publishing progress text.");
    self.publishing = YES;
    
    self.publishParameters.caption = self.captionTextView.text;
    self.publishParameters.captionType = VCaptionTypeNormal;
    
    self.publishParameters.shouldSaveToCameraRoll = self.saveContentCell.cameraRollSwitch.on;
    
    NSIndexSet *shareParams = self.shareContentCell.selectedShareTypes;
    self.publishParameters.shareToFacebook = [shareParams containsIndex:VShareTypeFacebook];
    self.publishParameters.shareToTwitter = [shareParams containsIndex:VShareTypeTwitter];
    
    [self trackPublishWithPublishParameters:self.publishParameters];
    
    __weak typeof(self) welf = self;
    [[VObjectManager sharedManager] uploadMediaWithPublishParameters:self.publishParameters
                                                          completion:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonResponse, NSError *error)
    {
         welf.publishing = NO;
         [hud hide:YES];
         if (error != nil)
         {
             UIAlertView *publishFailure = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Upload failure", @"")
                                                                      message:error.localizedDescription
                                                            cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                               onCancelButton:^
                                            {
                                                [welf closeOnComplete:NO];
                                            }
                                                   otherButtonTitlesAndBlocks:nil, nil];
             [publishFailure show];
         }
         else
         {
             [welf closeOnComplete:YES];
         }
     }];
}

- (void)trackPublishWithPublishParameters:(VPublishParameters *)publishParameters
{
    NSDictionary *common = @{ VTrackingKeyCaptionLength : @(publishParameters.caption .length),
                              VTrackingKeyDidSaveToDevice : @(publishParameters.shouldSaveToCameraRoll) };
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:common];
    if ( publishParameters.isVideo )
    {
        params[ VTrackingKeyContentType ] = VTrackingValueVideo;
        params[ VTrackingKeyDidTrim ] = @( publishParameters.didTrim );
    }
    else if ( publishParameters.isGIF )
    {
        params[ VTrackingKeyContentType ] = VTrackingValueGIF;
        params[ VTrackingKeyDidTrim ] = @( publishParameters.didTrim );
    }
    else
    {
        params[ VTrackingKeyContentType ] = VTrackingValueImage;
        params[ VTrackingKeyDidCrop ] = @( publishParameters.didCrop );
        params[ VTrackingKeyFilterName ] = publishParameters.filterName ?: @"";
        params[ VTrackingKeyTextType ] = publishParameters.textToolType ?: @"";
        params[ VTrackingKeyTextLength ] = @(publishParameters.embeddedText.length);
    }
    
    params[ VTrackingKeySharedToFacebook ] = @( publishParameters.shareToFacebook );
    params[ VTrackingKeySharedToTwitter ] = @( publishParameters.shareToTwitter );
    
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidPublishContent
                                       parameters:[NSDictionary dictionaryWithDictionary:params]];
}

- (IBAction)tappedCancel:(id)sender
{
    [self closeOnComplete:NO];
}

- (IBAction)dismiss:(UITapGestureRecognizer *)tapGesture
{
    if ((tapGesture.state == UIGestureRecognizerStateEnded) && (self.panGestureRecognizer.state == UIGestureRecognizerStateFailed))
    {
        if ([self.captionTextView isFirstResponder])
        {
            [self.captionTextView resignFirstResponder];
            return;
        }
        [self closeOnComplete:NO];
    }
}

#pragma mark - Exit

- (void)closeOnComplete:(BOOL)didPublish
{
    if ( !didPublish )
    {
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidCancelPublish];
    }
    
    if ( self.completion != nil )
    {
        self.completion( didPublish );
    }
}

#pragma mark - gesture handling

- (void)handleGestureBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint anchorPoint = [gestureRecognizer locationInView:self.view];
    CGPoint pointInContainer = [gestureRecognizer locationInView:self.publishPrompt];
    UIOffset offset = [self.publishPrompt v_centerOffsetForPoint:pointInContainer];

    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.publishPrompt
                                                        offsetFromCenter:offset
                                                        attachedToAnchor:anchorPoint];;
    self.attachmentBehavior.damping = 0.2f;
    [self.animator addBehavior:self.attachmentBehavior];
    [self.animator removeBehavior:self.snapBehavior];
}

- (void)handleGestureMoved:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint anchorPoint = [gestureRecognizer locationInView:self.view];
    self.attachmentBehavior.anchorPoint = anchorPoint;
}

- (void)handleGestureEnd:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self.animator removeBehavior:self.attachmentBehavior];
    
    __weak __typeof__(self) weakSelf = self;
    BOOL offScreen = CGRectIsNull(CGRectIntersection(self.view.bounds, self.publishPrompt.frame));
    if (offScreen && weakSelf.completion)
    {
        [weakSelf closeOnComplete:NO];
        return;
    }
    
    CGPoint velocity = [gestureRecognizer velocityInView:self.view];
    CGFloat velocityMagnitude = hypot(velocity.x, velocity.y);
    
    if (velocityMagnitude < kTriggerVelocity)
    {
        [self.animator addBehavior:self.snapBehavior];
    }
    else
    {
        CGPoint touchLocation = [gestureRecognizer locationInView:self.publishPrompt];
        UIOffset offset = [self.publishPrompt v_centerOffsetForPoint:touchLocation];
        
        [self.pushBehavior setTargetOffsetFromCenter:offset
                                        forItem:self.publishPrompt];
        
        self.pushBehavior.pushDirection = [self.publishPrompt v_forceFromVelocity:velocity
                                                                      withDensity:0.7f];
        self.pushBehavior.active = YES;
        [self.animator addBehavior:self.pushBehavior];
    }
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            [self handleGestureBegin:gestureRecognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self handleGestureMoved:gestureRecognizer];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self handleGestureEnd:gestureRecognizer];
            break;
        default:
            break;
    }
}

#pragma mark - UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior
      beganContactForItem:(id<UIDynamicItem>)item
   withBoundaryIdentifier:(id<NSCopying>)identifier
                  atPoint:(CGPoint)p
{
    if (self.publishing)
    {
        [self.animator addBehavior:self.snapBehavior];
        return;
    }
    
    [self.animator removeAllBehaviors];
    if (self.completion != nil)
    {
        [self closeOnComplete:NO];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound)
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL onCameraRollSwitch = CGRectContainsPoint(self.saveContentCell.cameraRollSwitch.bounds, [touch locationInView:self.saveContentCell.cameraRollSwitch]);
    BOOL onCaptionTextView = CGRectContainsPoint(self.captionTextView.bounds, [touch locationInView:self.captionTextView]);
    if (onCameraRollSwitch || onCaptionTextView)
    {
        return NO;
    }
    
    BOOL onPublishPrompt = CGRectContainsPoint(self.publishPrompt.bounds, [touch locationInView:self.publishPrompt]);
    if (onPublishPrompt && (gestureRecognizer == self.tapGestureRecognizer))
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - VContentInputAccessoryViewDelegate

- (BOOL)shouldLimitTextEntryForInputAccessoryView:(VContentInputAccessoryView *)inputAccessoryView
{
    return YES;
}

- (BOOL)shouldAddHashTagsForInputAccessoryView:(VContentInputAccessoryView *)inputAccessoryView
{
    return YES;
}

#pragma mark - Private Methods

- (void)setupBehaviors
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    // Our gestureRecognizer will modify and update this
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.publishPrompt]
                                                                    mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior = pushBehavior;
    
    // This will snap our content back to the center of the screen
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.publishPrompt
                                                    snapToPoint:CGPointMake(CGRectGetWidth(self.view.bounds) / 2,
                                                                            kTopSpacePublishPrompt + (CGRectGetHeight(self.publishPrompt.frame) * 0.5f))];
    snap.damping = kSnapDampingConstant;
    self.snapBehavior = snap;
    
    // This will be used for determining when the publish prompt has gone offscreen
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.publishPrompt]];
    collision.collisionDelegate = self;
    
    CGRect referenceBounds = self.publishPrompt.bounds;
    CGFloat inset = -hypot(CGRectGetWidth(referenceBounds), CGRectGetHeight(referenceBounds)); // hypot will ensure we are fully offscreen
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    [collision setTranslatesReferenceBoundsIntoBoundaryWithInsets:edgeInsets];
    
    [self.animator addBehavior:collision];
}

- (BOOL)isSaveCellAtIndexPath:(NSIndexPath *)indexPath
{
    //The save cell should ALWAYS be the last cell in the table
    return indexPath.row == [self.collectionView numberOfItemsInSection:indexPath.section] - 1;
}

- (void)shareCollectionViewSelectedShareItemCell:(VShareItemCollectionViewCell *)shareItemCell
{
    __weak VPublishViewController *weakSelf = self;
    if ( shareItemCell.shareMenuItem.shareType == VShareTypeFacebook )
    {
        if ( ![VFacebookManager sharedFacebookManager].authorizedToShare )
        {
            shareItemCell.state = VShareItemCellStateLoading;
            [[VFacebookManager sharedFacebookManager] requestPublishPermissionsOnSuccess:^
             {
                 shareItemCell.state = VShareItemCellStateSelected;
             }
                                                                               onFailure:^(NSError *error)
             {
                 [weakSelf showAlertForError:error fromShareItemCell:shareItemCell];
                 shareItemCell.state = VShareItemCellStateUnselected;
             }];
        }
        else
        {
            shareItemCell.state = VShareItemCellStateSelected;
        }
    }
    else if ( shareItemCell.shareMenuItem.shareType == VShareTypeTwitter )
    {
        if ( ![VTwitterManager sharedManager].authorizedToShare )
        {
            shareItemCell.state = VShareItemCellStateLoading;
            [[VTwitterManager sharedManager] refreshTwitterTokenWithIdentifier:[[VTwitterManager sharedManager] twitterId]
                                                            fromViewController:self
                                                               completionBlock:^(BOOL success, NSError *error)
             {
                 shareItemCell.state = success ? VShareItemCellStateSelected : VShareItemCellStateUnselected;
                 if ( !success )
                 {
                     [weakSelf showAlertForError:error fromShareItemCell:shareItemCell];
                 }
             }];
        }
        else
        {
            shareItemCell.state = VShareItemCellStateSelected;
        }
    }
}

- (void)showAlertForError:(NSError *)error fromShareItemCell:(VShareItemCollectionViewCell *)shareItemCell
{
    if ( [error.domain isEqualToString:VTwitterManagerErrorDomain] )
    {
        return;
    }
    
    __weak VPublishViewController *weakSelf = self;
    void (^retryBlock)(UIAlertAction *) = ^(UIAlertAction *action)
    {
        [weakSelf shareCollectionViewSelectedShareItemCell:shareItemCell];
    };
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:NSLocalizedString(@"Sorry, we were having some trouble on our end. Please retry.", @"")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    //We encountered a twitter API error
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", @"") style:UIAlertActionStyleDefault handler:retryBlock]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ( self.hasShareCell )
    {
        return 2;
    }
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    if ( [self isSaveCellAtIndexPath:indexPath] )
    {
        if ( self.saveContentCell == nil )
        {
            VPublishSaveCollectionViewCell *saveCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VPublishSaveCollectionViewCell suggestedReuseIdentifier] forIndexPath:indexPath];
            saveCell.dependencyManager = self.dependencyManager;
            self.saveContentCell = saveCell;
        }
        cell = self.saveContentCell;
    }
    else
    {
        if ( self.shareContentCell == nil )
        {
            VPublishShareCollectionViewCell *shareCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VPublishShareCollectionViewCell suggestedReuseIdentifier] forIndexPath:indexPath];
            shareCell.dependencyManager = self.dependencyManager;
            shareCell.delegate = self;
            self.shareContentCell = shareCell;
        }
        cell = self.shareContentCell;
    }
    return cell;
}

#pragma mark - Layout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;
    if ( [self isSaveCellAtIndexPath:indexPath] )
    {
        size.height = [VPublishSaveCollectionViewCell desiredHeight];
    }
    else
    {
        size.height = [VPublishShareCollectionViewCell desiredHeightForDependencyManager:self.dependencyManager];
    }
    size.width = self.cellWidth;
    return size;
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.view;
}

@end

static NSString * const kPublishScreenKey = @"publishScreen";

@implementation VDependencyManager (VPublishViewController)

- (VPublishViewController *)newPublishViewController
{
    return (VPublishViewController *)[self viewControllerForKey:kPublishScreenKey];
}

@end
