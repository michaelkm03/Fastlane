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

@import AssetsLibrary;

static const CGFloat kTriggerVelocity = 500.0f;
static const CGFloat kSnapDampingConstant = 0.9f;
static const CGFloat kTopSpacePublishPrompt = 50.0f;
static const CGFloat kAccessoryViewHeight = 44.0f;

@interface VPublishViewController () <UICollisionBehaviorDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, VContentInputAccessoryViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UIView *publishPrompt;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet VPlaceholderTextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;
@property (weak, nonatomic) IBOutlet UILabel *saveToCameraRollLabel;
@property (weak, nonatomic) IBOutlet UISwitch *cameraRollSwitch;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UISnapBehavior *snapBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, copy, readwrite) void (^animateInBlock)(void);

@property (nonatomic, assign) BOOL publishing;

@end

@implementation VPublishViewController

#pragma mark - VHasManagedDependancies

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
    
    self.publishButton.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    [self.publishButton setTitleColor:[self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey]
                             forState:UIControlStateNormal];
    self.captionTextView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.saveToCameraRollLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
    self.cameraRollSwitch.onTintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    
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

    self.captionTextView.placeholderText = NSLocalizedString(@"Write a caption (optional)", @"Caption entry placeholder text");
    UIFont *label3Font = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    if (label3Font != nil)
    {
        self.captionTextView.typingAttributes = @{NSFontAttributeName: label3Font};
    }
    
    VContentInputAccessoryView *inputAccessoryView = [[VContentInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), kAccessoryViewHeight)];
    self.captionTextView.textContainerInset = UIEdgeInsetsMake(10, 6, 0, 6);
    self.captionTextView.backgroundColor = [UIColor clearColor];
    inputAccessoryView.textInputView = self.captionTextView;
    inputAccessoryView.maxCharacterLength = 120;
    inputAccessoryView.delegate = self;
    inputAccessoryView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.captionTextView.inputAccessoryView = inputAccessoryView;
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    UIFont *headerFont = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    if (headerFont != nil)
    {
        attributes[NSFontAttributeName] = headerFont;
    }
    self.cancelButton.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Cancel", @"")
                                                                                  attributes:attributes];
    UIColor *textColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    [self.cancelButton setTitleColor:textColor ?: [UIColor whiteColor]
                            forState:UIControlStateNormal];
    
    self.previewImageView.image = self.publishParameters.previewImage;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self setupBehaviors];
    
    CGRect referenceBounds = self.publishPrompt.bounds;
    CGFloat inset = -hypot(CGRectGetWidth(referenceBounds), CGRectGetHeight(referenceBounds)); // hypot will ensure we are fully offscreen
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:edgeInsets];
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
    self.publishParameters.shouldSaveToCameraRoll = self.cameraRollSwitch.on;
    
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
                                                            cancelButtonTitle:NSLocalizedString(@"ok", @"")
                                                               onCancelButton:^{
                                                                   if (welf.completion != nil)
                                                                   {
                                                                       welf.completion(NO);
                                                                   }
                                                               } otherButtonTitlesAndBlocks:nil, nil];
             [publishFailure show];
         }
         else
         {
             if (welf.completion != nil)
             {
                 welf.completion(YES);
             }
         }
     }];
}

- (IBAction)tappedCancel:(id)sender
{
    if (self.completion != nil)
    {
        self.completion(NO);
    }
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
        if (self.completion != nil)
        {
            self.completion(NO);
        }
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
        weakSelf.completion(NO);
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
        self.completion(NO);
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
    BOOL onCameraRollSwitch = CGRectContainsPoint(self.cameraRollSwitch.bounds, [touch locationInView:self.cameraRollSwitch]);
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
    self.collisionBehavior = collision;
    [self.animator addBehavior:collision];
}

@end
