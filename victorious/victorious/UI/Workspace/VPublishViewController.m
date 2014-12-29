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

#import "VObjectManager+ContentCreation.h"

#import <MBProgressHUD/MBProgressHUD.h>

static const CGFloat kTriggerVelocity = 500.0f;
static const CGFloat kSnapDampingConstant = 0.9f;
static const CGFloat kTopSpacePublishPrompt = 50.0f;

@interface VPublishViewController () <UICollisionBehaviorDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UIView *publishPrompt;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet VPlaceholderTextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UISnapBehavior *snapBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;

@property (nonatomic, copy, readwrite) void (^animateInBlock)(void);

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
    
    self.publishButton.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    self.publishButton.titleLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.captionTextView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    
    __weak typeof(self) welf = self;
    self.publishPrompt.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    self.animateInBlock = ^void(void)
    {
        welf.publishPrompt.transform = CGAffineTransformIdentity;
    };
    
    [self setupBehaviors];
    
    self.previewImageView.image = self.previewImage;

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    self.captionTextView.placeholderText = NSLocalizedString(@"TYPE A CAPTION & ADD AN #HASHTAG", @"Caption entry placeholder text");
    self.captionTextView.typingAttributes = @{NSFontAttributeName: [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey],
                                              NSParagraphStyleAttributeName: paragraphStyle};
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect referenceBounds = self.animator.referenceView.bounds;
    CGFloat inset = -hypot(CGRectGetWidth(referenceBounds), CGRectGetHeight(referenceBounds)); // hypot will ensure we are fully offscreen
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:edgeInsets];
}

#pragma mark - Property Accessors

- (void)setPreviewImage:(UIImage *)previewImage
{
    _previewImage = previewImage;
    
    self.previewImageView.image = previewImage;
}

#pragma mark - Target/Action

- (IBAction)publish:(id)sender
{
    [[VObjectManager sharedManager] uploadMediaWithName:self.captionTextView.text
                                            description:nil
                                           previewImage:self.previewImage
                                            captionType:VCaptionTypeQuote
                                              expiresAt:nil
                                       parentSequenceId:nil
                                           parentNodeId:nil
                                                  speed:1.0f
                                               loopType:VLoopOnce
                                               mediaURL:self.mediaToUploadURL
                                          facebookShare:NO
                                           twitterShare:NO
                                             completion:^(NSURLResponse *response, NSData *responseData, NSDictionary *jsonResponse, NSError *error)
     {
         if (error)
         {
             if (self.completion)
             {
                 self.completion(NO);
             }
         }
         else
         {
             if (self.completion)
             {
                 self.completion(YES);
             }
         }
     }];
}

- (IBAction)dismiss:(UITapGestureRecognizer *)tapGesture
{
    if ((tapGesture.state == UIGestureRecognizerStateEnded) && (self.panGestureRecognizer.state == UIGestureRecognizerStateFailed))
    {
        if (self.completion)
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
    [self.animator removeAllBehaviors];
    if (self.completion)
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
    if (CGRectContainsPoint(self.publishPrompt.frame, [touch locationInView:self.view]))
    {
        return NO;
    }
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
    
    // This will be used for determining when the publish prompt has gone offscreen
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.publishPrompt]];
    collision.collisionDelegate = self;
    self.collisionBehavior = collision;
    [self.animator addBehavior:collision];
    
    // This will snap our content back to the center of the screen
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.publishPrompt
                                                    snapToPoint:CGPointMake(self.view.center.x,
                                                                            kTopSpacePublishPrompt + (CGRectGetHeight(self.publishPrompt.frame) * 0.5f))];
    snap.damping = kSnapDampingConstant;
    self.snapBehavior = snap;
}

@end
