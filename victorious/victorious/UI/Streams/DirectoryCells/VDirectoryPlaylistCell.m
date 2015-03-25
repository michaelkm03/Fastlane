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

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelContainerHeightConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelRightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelBottomConstraint;

@property (nonatomic, assign) CGFloat preferredContainerHeight;

@property (nonatomic, assign) BOOL addedParallaxEffect;

@end

static const CGFloat kTextInset = 8.0f;
static const CGFloat kParallaxMovementAmount = 30.0f;

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
    
    self.preferredContainerHeight = self.labelContainerHeightConstraint.constant;
    
    if ( !self.addedParallaxEffect )
    {
        self.addedParallaxEffect = YES;
        [self.previewImageView v_addMotionEffectsWithMagnitude: - kParallaxMovementAmount];
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
    
    CGFloat containerHeight = self.preferredContainerHeight;
    CGFloat fittingContainerHeight = kTextInset * 2 + textHeight;
    if ( containerHeight < fittingContainerHeight )
    {
        //If the height 
        containerHeight = fittingContainerHeight;
    }
    self.labelContainerHeightConstraint.constant = containerHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect parallaxViewFrame = CGRectInset(self.bounds, - kParallaxMovementAmount, - kParallaxMovementAmount);
    parallaxViewFrame.origin.y = ( self.parallaxYOffset * ( kParallaxMovementAmount / 2 ) ) - ( kParallaxMovementAmount / 2 );
    [self.previewImageView setFrame:parallaxViewFrame];
}

- (void)setParallaxYOffset:(CGFloat)parallaxYOffset
{
    _parallaxYOffset = parallaxYOffset;
    if ( [self.stream.name isEqualToString:@"Goro Stream"] )
    {
        NSLog(@"offset is %f", parallaxYOffset);
    }
    CGRect parallaxViewFrame = self.previewImageView.frame;
    parallaxViewFrame.origin.y = ( parallaxYOffset * ( kParallaxMovementAmount / 2 ) ) - ( kParallaxMovementAmount / 2 );
    [self.previewImageView setFrame:parallaxViewFrame];
}


- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    self.labelContainer.backgroundColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    self.nameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    self.nameLabel.font = [dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
}

@end
