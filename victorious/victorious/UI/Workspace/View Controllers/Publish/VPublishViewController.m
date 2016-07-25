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
#import "VDependencyManager+VLoginAndRegistration.h"
#import "VPlaceholderTextView.h"
#import "VContentInputAccessoryView.h"
#import "VPublishParameters.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NSURL+MediaType.h"
#import "VPublishSaveCollectionViewCell.h"
#import "VPublishShareCollectionViewCell.h"
#import "VShareItemCollectionViewCell.h"
#import "VShareMenuItem.h"
#import "VDependencyManager+VShareMenuItem.h"
#import "VTwitterManager.h"
#import "VDependencyManager+VBackgroundContainer.h"
#import "VDependencyManager+VKeyboardStyle.h"
#import "VPermissionPhotoLibrary.h"
#import "VDependencyManager+VTracking.h"
#import "VPermissionsTrackingHelper.h"
#import "VAlongsidePresentationAnimator.h"
#import "victorious-Swift.h"

@import AssetsLibrary;
@import FBSDKCoreKit;
@import FBSDKLoginKit;

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
static NSString * const kEnableMediaSaveKey = @"autoEnableMediaSave";
static NSString * const kFBPermissionPublishActionsKey = @"publish_actions";

@interface VPublishViewController () <UICollisionBehaviorDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, VContentInputAccessoryViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, VPublishShareCollectionViewCellDelegate, VBackgroundContainer, VAlongsidePresentation>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) IBOutlet UIVisualEffectView *blurView;
@property (nonatomic, weak) IBOutlet UIView *publishPrompt;
@property (nonatomic, weak) IBOutlet UIView *captionContainer;
@property (nonatomic, weak) IBOutlet UIImageView *captionSeparator;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet VPlaceholderTextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton; // hidden in the nib
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) VPublishSaveCollectionViewCell *saveContentCell;
@property (nonatomic, strong) VPublishShareCollectionViewCell *shareContentCell;
@property (nonatomic, strong) VPermissionPhotoLibrary *photoLibraryPermission;
@property (nonatomic, assign) BOOL hasShareCell;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *cardHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *previewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *dividerLineHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *publishButtonHeightConstraint;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UISnapBehavior *snapBehavior;

@property (nonatomic, assign) BOOL publishing;

@property (nonatomic, strong) VPermissionsTrackingHelper *permissionsTrackingHelper;

@end

@implementation VPublishViewController

#pragma mark - VHasManagedDependencies

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundleForClass = [NSBundle bundleForClass:self];
    VPublishViewController *publishViewController = [[VPublishViewController alloc] initWithNibName:NSStringFromClass([VPublishViewController class])
                                                                                             bundle:bundleForClass];
    publishViewController.dependencyManager = dependencyManager;
    return publishViewController;
}

#pragma mark - dealloc

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
    _panGestureRecognizer.delegate = nil;
    _tapGestureRecognizer.delegate = nil;
    _captionTextView.delegate = nil;
}

#pragma mark - UIViewController

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dependencyManager trackViewWillAppear:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.dependencyManager trackViewWillDisappear:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    self.photoLibraryPermission = [[VPermissionPhotoLibrary alloc] initWithDependencyManager:self.dependencyManager];
    
    [self setupCollectionView];
    
    [self.dependencyManager addBackgroundToBackgroundHost:self];
    
    self.publishButton.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self.publishButton setTitleColor:[self.dependencyManager colorForKey:VDependencyManagerSecondaryLinkColorKey]
                             forState:UIControlStateNormal];
    [self.publishButton.titleLabel setFont:[self.dependencyManager fontForKey:VDependencyManagerButton1FontKey]];
    
    NSUInteger random = arc4random_uniform(100);
    CGFloat randomFloat = random / 100.0f;
    CGAffineTransform initialTransformTranslation = CGAffineTransformMakeTranslation(0, -CGRectGetMidY(self.view.frame));
    CGAffineTransform initialTransformRotation = CGAffineTransformMakeRotation(M_PI * (1-randomFloat));
    self.publishPrompt.transform = CGAffineTransformConcat(initialTransformTranslation, initialTransformRotation);
    self.publishButton.accessibilityIdentifier = VAutomationIdentifierPublishFinish;
    
    [self setupCaptionTextView];
    
    self.captionSeparator.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    
    [self.cancelButton setTitle:[self.dependencyManager stringForKey:kBackButtonTitleKey]
                       forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [self.dependencyManager fontForKey:VDependencyManagerButton2FontKey];
    UIColor *textColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey];
    [self.cancelButton setTitleColor:textColor ?: [UIColor whiteColor]
                            forState:UIControlStateNormal];
    self.cancelButton.hidden = NO;
    self.previewImageView.image = self.publishParameters.previewImage;
    
    [self setupShareCard];
    
    self.permissionsTrackingHelper = [[VPermissionsTrackingHelper alloc] init];
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
    self.captionTextView.textContainerInset = UIEdgeInsetsMake( 4.0, 0.0, 4.0, 0.0 );
    [self.captionTextView setPlaceholderTextColor:[self.dependencyManager colorForKey:VDependencyManagerPlaceholderTextColorKey]];
    self.captionTextView.textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.captionTextView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.captionTextView.accessibilityIdentifier = VAutomationIdentifierPublishCatpionText;
    
    NSString *placeholderText = [self.dependencyManager stringForKey:kPlaceholderTextKey];
    self.captionTextView.placeholderText = placeholderText;
    self.captionTextView.accessibilityLabel = placeholderText;
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
}

- (CGFloat)calculatedCellWidth
{
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    width -= contentInset.right + contentInset.left;
    UIEdgeInsets sectionInset = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).sectionInset;
    width -= sectionInset.right + sectionInset.left;
    
    return width;
}

- (void)setupShareCard
{
    self.hasShareCell = [self.dependencyManager shareMenuItems].count != 0;
    
    CGFloat staticHeights = self.publishButtonHeightConstraint.constant + self.previewHeightConstraint.constant + self.dividerLineHeightConstraint.constant;
    CGFloat shareHeight = [VPublishShareCollectionViewCell desiredHeightForDependencyManager:self.dependencyManager];
    if ( shareHeight != 0 )
    {
        shareHeight += kCollectionViewVerticalSpace;
    }
    CGFloat collectionViewHeight = 0.0f;
    if ( self.hasShareCell )
    {
        collectionViewHeight += shareHeight + kCollectionViewVerticalSpace;
    }
    if ( !self.publishParameters.isGIF )
    {
        collectionViewHeight += [VPublishSaveCollectionViewCell desiredHeight] + kCollectionViewVerticalSpace;
    }
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
    else
    {
        // Snapshot the current state of the window to preserve blurring
        // as it animates away with the rest of the creation flow
        UIView *snapshot = [self.view.window snapshotViewAfterScreenUpdates:NO];
        [self.view addSubview:snapshot];
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

#pragma mark - Custom actions

- (void)toggledSaveSwitch:(UISwitch *)saveSwitch
{
    if ( saveSwitch.on && self.photoLibraryPermission.permissionState != VPermissionStateAuthorized )
    {
        if ( self.photoLibraryPermission.permissionState == VPermissionStateSystemDenied )
        {
            [self showGrantCameraPermissionThroughSettingsAlert];
        }
        else
        {
            [self showCameraPermissionsRequest];
        }
    }
}

- (void)showGrantCameraPermissionThroughSettingsAlert
{
    //Denied the system prompt, display an alert to let them know they need to go grant it through settings
    UIAlertController *deniedAlertController = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:NSLocalizedString(@"CameraRollDenied", nil) preferredStyle:UIAlertControllerStyleAlert];
    __weak VPublishViewController *weakSelf = self;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
                               {
                                   weakSelf.saveContentCell.cameraRollSwitch.on = NO;
                               }];
    [deniedAlertController addAction:okAction];
    [self presentViewController:deniedAlertController
                       animated:YES
                     completion:nil];
}

- (void)showCameraPermissionsRequest
{
    __weak VPublishViewController *weakSelf = self;
    [self.photoLibraryPermission requestPermissionInViewController:self
                                             withCompletionHandler:^(BOOL granted, VPermissionState state, NSError *error)
     {
         VPublishViewController *strongSelf = weakSelf;
         if ( strongSelf == nil )
         {
             return;
         }
         
         UISwitch *saveSwitch = strongSelf.saveContentCell.cameraRollSwitch;
         saveSwitch.on = granted;
         if ( granted )
         {
             [saveSwitch removeTarget:strongSelf action:@selector(toggledSaveSwitch:) forControlEvents:UIControlEventValueChanged];
             [self.permissionsTrackingHelper permissionsDidChange:VTrackingValuePhotolibraryDidAllow permissionState:VTrackingValueAuthorized];
         }
         if ( state == VPermissionStatePromptDenied )
         {
             //Already shown the first prompt once, no reason to show it again
             strongSelf.photoLibraryPermission.shouldShowInitialPrompt = NO;
             [self.permissionsTrackingHelper permissionsDidChange:VTrackingValuePhotolibraryDidAllow permissionState:VTrackingValueDenied];
         }
     }];
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

- (void)saveMediaToCameraRollFromURL:(NSURL *)sourceUrl
{
    if ( self.publishParameters.isVideo )
    {
        // Video compatibility check is skipped here
        UISaveVideoAtPathToSavedPhotosAlbum([sourceUrl relativePath], self, @selector(savingToCameraRollCompletionForVideo:didFinishSavingWithError:contextInfo:), nil);
    }
    else
    {
        UIImageWriteToSavedPhotosAlbum(self.publishParameters.previewImage, self, @selector(savingToCameraRollCompletionForImage:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)savingToCameraRollCompletionForImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self removeUploadedTempFiles];
    [self logMediaSavingProcess:error];
}

- (void)savingToCameraRollCompletionForVideo:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [self removeUploadedTempFiles];
    [self logMediaSavingProcess:error];
}

- (void)logMediaSavingProcess:(NSError *)error
{
    if ( error == nil )
    {
        VLog(@"Saved media to camera roll successfully");
    }
    else
    {
        VLog(@"Failed to save media to camera roll with error information: %@", error);
    }
}

- (void)removeUploadedTempFiles
{
    [[NSFileManager defaultManager] removeItemAtURL:self.publishParameters.mediaToUploadURL error:nil];
}

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
    return ( indexPath.row == [self.collectionView numberOfItemsInSection:indexPath.section] - 1 && !self.publishParameters.isGIF );
}

- (void)shareCollectionViewSelectedShareItemCell:(VShareItemCollectionViewCell *)shareItemCell
{
    __weak VPublishViewController *weakSelf = self;
    if ( shareItemCell.shareMenuItem.shareType == VShareTypeFacebook )
    {
        if ( ![[[FBSDKAccessToken currentAccessToken] permissions] containsObject:kFBPermissionPublishActionsKey] )
        {
            shareItemCell.state = VShareItemCellStateLoading;
            
            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
            [loginManager logInWithPublishPermissions:@[kFBPermissionPublishActionsKey]
                                   fromViewController:self
                                              handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
            {
                if ( [result.grantedPermissions containsObject:kFBPermissionPublishActionsKey] )
                {
                    shareItemCell.state = VShareItemCellStateSelected;
                }
                else
                {
                    if ( !result.isCancelled && error != nil )
                    {
                        [weakSelf showAlertForError:error fromShareItemCell:shareItemCell];
                    }
                    shareItemCell.state = VShareItemCellStateUnselected;
                }
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
            [[VTwitterManager sharedManager] refreshTwitterTokenFromViewController:self
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
    NSString *alertMessage = NSLocalizedString(@"Sorry, we were having some trouble on our end. Please retry.", @"");
    __weak VPublishViewController *weakSelf = self;
    void (^retryBlock)(UIAlertAction *) = ^(UIAlertAction *action)
    {
        [weakSelf shareCollectionViewSelectedShareItemCell:shareItemCell];
    };
    UIAlertAction *retryAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", @"") style:UIAlertActionStyleDefault handler:retryBlock];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    NSArray *actions = @[ cancelAction, retryAction ];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    for ( UIAlertAction *action in actions )
    {
        [alertController addAction:action];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ( self.hasShareCell || !self.publishParameters.isGIF )
    {
        return 1;
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ( self.hasShareCell && !self.publishParameters.isGIF )
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
            
            //Determine switch state
            if ( self.photoLibraryPermission.permissionState == VPermissionStateAuthorized )
            {
                NSNumber *autoEnableSave = [_dependencyManager numberForKey:kEnableMediaSaveKey];
                if ( autoEnableSave != nil )
                {
                    saveCell.cameraRollSwitch.on = [autoEnableSave boolValue];
                }
                else
                {
                    saveCell.cameraRollSwitch.on = YES;
                }
            }
            else
            {
                [saveCell.cameraRollSwitch addTarget:self action:@selector(toggledSaveSwitch:) forControlEvents:UIControlEventValueChanged];
            }
            
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
    size.width = [self calculatedCellWidth];
    return size;
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.blurView.contentView;
}

#pragma mark - VAlongsidePresentation

- (void)alongsidePresentation
{
    // force view to load
    self.view.alpha = 1.0f;
    
    self.blurView.alpha = 1.0f;
    self.publishPrompt.transform = CGAffineTransformIdentity;
}

- (void)alongsideDismissal
{
    self.view.alpha = 0.0f;
}

@end

static NSString * const kPublishScreenKey = @"publishScreen";

@implementation VDependencyManager (VPublishViewController)

- (VPublishViewController *)newPublishViewController
{
    return (VPublishViewController *)[self viewControllerForKey:kPublishScreenKey];
}

@end
