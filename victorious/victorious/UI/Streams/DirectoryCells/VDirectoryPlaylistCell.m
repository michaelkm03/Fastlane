//
//  VDirectoryPlaylistCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectoryPlaylistCell.h"
#import "UIImageView+VLoadingAnimations.h"
#import "VStreamItem+Fetcher.h"
#import "VStream+Fetcher.h"
#import "VDependencyManager.h"
#import "UIView+MotionEffects.h"

@interface VDirectoryPlaylistCell ()

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

static const CGFloat kTextInset = 8.0f;
static const CGFloat kParallaxMovementAmount = 30.0f;
static const CGFloat kPreferredLabelHeight = 27.0f;
static const CGFloat kPreferredContainerHeight = kPreferredLabelHeight + ( kTextInset * 2 );

@implementation VDirectoryPlaylistCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //Resetting constants is less
    NSArray *layoutConstraints = @[ self.labelTopConstraint, self.labelRightConstraint, self.labelLeftConstraint, self.labelBottomConstraint ];
    for ( NSLayoutConstraint *constraint in layoutConstraints )
    {
        constraint.constant = kTextInset;
    }
    
    self.previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
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
    UILabel *nameLabel = self.nameLabel;
    [nameLabel setText:text];
    NSDictionary *attributes = nil;
    UIFont *font = nameLabel.font;
    if ( nameLabel.font )
    {
        attributes = @{ NSFontAttributeName : font };
    }
    CGSize maxSize = CGSizeMake(CGRectGetWidth(nameLabel.bounds), CGFLOAT_MAX);
    CGFloat textHeight = CGRectGetHeight([text boundingRectWithSize:maxSize
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
    
    CGRect parallaxViewFrame = CGRectInset(self.bounds, 0, - kParallaxMovementAmount);
    [self updateParallaxEffectForFrame:parallaxViewFrame];
}

- (void)setParallaxYOffset:(CGFloat)parallaxYOffset
{
    _parallaxYOffset = parallaxYOffset;
    [self updateParallaxEffectForFrame:self.previewImageView.frame];
}

- (void)updateParallaxEffectForFrame:(CGRect)frame
{
    frame.origin.y = ( self.parallaxYOffset * ( kParallaxMovementAmount / 2 ) ) - ( kParallaxMovementAmount / 2 );
    if ( !CGRectEqualToRect(self.previewImageView.frame, frame) )
    {
        [self.previewImageView setFrame:frame];
    }
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    self.labelContainer.backgroundColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.nameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    self.nameLabel.font = [dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
}

@end
