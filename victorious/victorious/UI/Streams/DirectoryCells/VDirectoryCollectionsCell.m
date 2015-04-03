//
//  VDirectoryPlaylistCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectoryCollectionsCell.h"
#import "UIImageView+VLoadingAnimations.h"
#import "VStreamItem+Fetcher.h"
#import "VStream+Fetcher.h"
#import "VDependencyManager.h"
#import "UIView+MotionEffects.h"

static const CGFloat kTextInset = 8.0f;
static const CGFloat kParallaxScrollMovementAmount = 30.0f;
static const CGFloat kParallaxTiltMovementAmount = 10.0f;
static const CGFloat kPreferredLabelHeight = 27.0f;
static const CGFloat kPreferredContainerHeight = kPreferredLabelHeight + ( kTextInset * 2 );
static const CGFloat kContentRatio = 0.4375; //140 / 320 (from spec)

//Animation constants
static const CGFloat kAnimationDuration = 0.5f;
static const CGFloat kSpringDamping = 0.7f;
static const CGFloat kInitialSpringVelocity = 0.4f;
static const CGFloat kStartAnimationScale = 0.8f;


@interface VDirectoryCollectionsCell ()

/**
 The label that will hold the streamItem name
 */
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

/**
 The view that will hold the name label
 */
@property (nonatomic, weak) IBOutlet UIView *labelContainer;

/**
 The image that will hold the streamItem icon
 */
@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;

/**
 Describes the height of the view containing the name label
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelContainerHeightConstraint;

/**
 Describe the left, right, top, and bottom constraints used to inset the label from it's containing view
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelBottomConstraint;

@end

@implementation VDirectoryCollectionsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //Resetting constants is less
    NSArray *layoutConstraints = @[ self.labelTopConstraint, self.labelRightConstraint, self.labelLeftConstraint, self.labelBottomConstraint ];
    for ( NSLayoutConstraint *constraint in layoutConstraints )
    {
        constraint.constant = kTextInset;
    }
    [self layoutIfNeeded];
    
    self.previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.previewImageView v_addMotionEffectsWithMagnitude:kParallaxTiltMovementAmount];
}

- (void)animate:(BOOL)animate toVisible:(BOOL)visible afterDelay:(CGFloat)delay
{
    CGFloat targetAlpha = 1.0f;
    CGFloat targetTransform = 1.0f;
    if ( !visible )
    {
        targetAlpha = 0.0f;
        targetTransform = kStartAnimationScale;
    }
    
    if ( animate )
    {
        [UIView animateWithDuration:kAnimationDuration
                              delay:delay
             usingSpringWithDamping:kSpringDamping
              initialSpringVelocity:kInitialSpringVelocity
                            options:0
                         animations:^
        {
            self.alpha = targetAlpha;
            self.transform = CGAffineTransformMakeScale(targetTransform, targetTransform);
                         }
                         completion:nil];
    }
    else
    {
        self.alpha = targetAlpha;
        self.transform = CGAffineTransformMakeScale(targetTransform, targetTransform);
    }
}

- (void)setStream:(VStreamItem *)stream
{
    _stream = stream;
    id previewImageObject = stream.previewImagesObject;
    NSString *imageURL = nil;
    if ( [previewImageObject isKindOfClass:[NSArray class]] )
    {
        imageURL = [previewImageObject firstObject];
    }
    else if ( [previewImageObject isKindOfClass:[NSString class]] )
    {
        imageURL = previewImageObject;
    }
    [self.previewImageView fadeInImageAtURL:[NSURL URLWithString:imageURL]
                           placeholderImage:nil];
    [self updateNameLabelText:stream.name];
}

- (void)updateNameLabelText:(NSString *)text
{
    [self.nameLabel setText:text];
    [self updateNameLabelConstraints];
}

- (void)updateNameLabelConstraints
{
    UILabel *nameLabel = self.nameLabel;
    NSDictionary *attributes = nil;
    UIFont *font = nameLabel.font;
    if ( nameLabel.font )
    {
        attributes = @{ NSFontAttributeName : font };
    }
    CGFloat width = CGRectGetWidth(nameLabel.bounds);
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    CGFloat textHeight = CGRectGetHeight([self.nameLabel.text boundingRectWithSize:maxSize
                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:attributes
                                                                           context:NULL]);
    
    CGFloat containerHeight = kPreferredContainerHeight;
    CGFloat fittingContainerHeight = kTextInset * 2 + textHeight;
    if ( containerHeight < fittingContainerHeight )
    {
        //If our preferred container height is too short to properly fit the text, then use the newly calculated fittingContainerHeight
        containerHeight = fittingContainerHeight;
    }
    self.labelContainerHeightConstraint.constant = containerHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect parallaxViewFrame = CGRectInset( self.bounds, - kParallaxTiltMovementAmount, - ( kParallaxScrollMovementAmount + kParallaxTiltMovementAmount ) );
    [self updateParallaxEffectForFrame:parallaxViewFrame];
}

- (void)setParallaxYOffset:(CGFloat)parallaxYOffset
{
    _parallaxYOffset = parallaxYOffset;
    [self updateParallaxEffectForFrame:self.previewImageView.frame];
}

- (void)updateParallaxEffectForFrame:(CGRect)frame
{
    frame.origin.y = ( self.parallaxYOffset * ( kParallaxScrollMovementAmount / 2 ) ) - ( kParallaxScrollMovementAmount / 2 );
    if ( !CGRectEqualToRect(self.previewImageView.frame, frame) )
    {
        self.previewImageView.frame = frame;
        [self layoutIfNeeded];
    }
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    if ( dependencyManager != nil )
    {
        self.labelContainer.backgroundColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
        self.nameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.nameLabel.font = [dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
        [self updateNameLabelConstraints];
    }
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    return CGSizeMake( width, kContentRatio * width );
}

@end
