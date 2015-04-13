//
//  VFullscreenMarqueeStreamItemCell.m
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFullscreenMarqueeStreamItemCell.h"

// Stream Support
#import "VStreamItem+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VUser.h"
#import "VSettingManager.h"
#import "VStreamWebViewController.h"

// Views + Helpers
#import "VDefaultProfileButton.h"
#import "UIView+Autolayout.h"
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"
#import "VThemeManager.h"

// Dependencies
#import "VDependencyManager.h"

CGFloat const kVDetailVisibilityDuration = 3.0f;
CGFloat const kVDetailHideDuration = 2.0f;
static CGFloat const kVDetailHideTime = 20.3f;
static CGFloat const kVDetailBounceHeight = 8.0f;
static CGFloat const kVDetailBounceTime = 0.15f;
static CGFloat const kTitleOffsetForTemplateC = 6.5f;
static CGFloat const kVCellHeightRatio = 0.884375; //from spec, 283 height for 320 width
static NSString * const kVOrIconKey = @"orIcon";

@interface VFullscreenMarqueeStreamItemCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, weak) IBOutlet UIView *loadingBackgroundContainer;
@property (nonatomic, weak) IBOutlet UIView *detailsContainer;
@property (nonatomic, weak) IBOutlet UIView *detailsBackgroundView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *detailsBottomLayoutConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelTopLayoutConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *labelBottomLayoutConstraint;

@property (nonatomic, weak) IBOutlet VDefaultProfileButton *profileImageButton;

@property (nonatomic, strong) NSTimer *hideTimer;

@end

@implementation VFullscreenMarqueeStreamItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.profileImageButton.layer.borderWidth = CGRectGetHeight(self.profileImageButton.bounds) / 2;
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    [super setStreamItem:streamItem];
    
    self.nameLabel.text = streamItem.name;

    NSURL *previewImageUrl = [NSURL URLWithString: [streamItem.previewImagePaths firstObject]];
    [self.previewImageView fadeInImageAtURL:previewImageUrl
                           placeholderImage:nil];
    
    self.detailsBackgroundView.backgroundColor = [[VThemeManager sharedThemeManager] preferredBackgroundColor];
    
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        VSequence *sequence = (VSequence *)streamItem;
        
        self.pollOrImageView.hidden = ![sequence isPoll];
        
        [self.profileImageButton setProfileImageURL:[NSURL URLWithString:sequence.user.pictureUrl]
                                           forState:UIControlStateNormal];
    }
    else
    {
        self.profileImageButton.hidden = YES;
    }
    
    //Timer for marquee details auto-hiding
    [self setDetailsContainerVisible:YES animated:NO];
    [self restartHideTimer];
}

- (void)setHideMarqueePosterImage:(BOOL)hideMarqueePosterImage
{
    if ( self.hideMarqueePosterImage == hideMarqueePosterImage )
    {
        return;
    }
    
    _hideMarqueePosterImage = hideMarqueePosterImage;
    self.profileImageButton.hidden = self.hideMarqueePosterImage;
    if ( self.hideMarqueePosterImage )
    {
        self.labelTopLayoutConstraint.constant -= kTitleOffsetForTemplateC;
        self.labelBottomLayoutConstraint.constant += kTitleOffsetForTemplateC;
        [self layoutIfNeeded];
    }
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    if ( dependencyManager != nil )
    {
        self.detailsBackgroundView.backgroundColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
        self.nameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.profileImageButton.layer.borderColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey].CGColor;
        self.nameLabel.font = [dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
        UIImage *orIcon = [dependencyManager imageForKey:kVOrIconKey];
        self.pollOrImageView.image = orIcon;
    }
}

- (void)restartHideTimer
{
    [self.hideTimer invalidate];
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:kVDetailVisibilityDuration
                                                      target:self
                                                    selector:@selector(hideDetailContainer)
                                                    userInfo:nil
                                                     repeats:NO];
}

#pragma mark - Detail container animation

//Selector hit by timer
- (void)hideDetailContainer
{
    [self setDetailsContainerVisible:NO animated:YES];
}

- (void)setDetailsContainerVisible:(BOOL)visible animated:(BOOL)animated
{
    CGFloat targetConstraintValue = visible ? -kVDetailBounceHeight : - self.detailsContainer.bounds.size.height;
    
    [self cancelDetailsAnimation];
    if ( animated )
    {
        [UIView animateWithDuration:kVDetailBounceTime animations:^
        {
            self.detailsBottomLayoutConstraint.constant = 0.0f;
            [self layoutIfNeeded];
        }
        completion:^(BOOL finished)
        {
            [UIView animateWithDuration:kVDetailHideTime animations:^
             {
                 self.detailsBottomLayoutConstraint.constant = targetConstraintValue;
                 [self layoutIfNeeded];
             }];
        }];
    }
    else
    {
        self.detailsBottomLayoutConstraint.constant = targetConstraintValue;
    }
}

- (void)cancelDetailsAnimation
{
    [((UIView *)self.detailsBottomLayoutConstraint.firstItem).layer removeAllAnimations];
    [((UIView *)self.detailsBottomLayoutConstraint.secondItem).layer removeAllAnimations];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = floorf(width * kVCellHeightRatio);
    return CGSizeMake(width, height);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self setDetailsContainerVisible:YES animated:NO];
}

- (IBAction)userSelected:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cell:selectedUser:)])
    {
        [self.delegate cell:self selectedUser:((VSequence *)self.streamItem).user];
    }
}

#pragma mark - VBackgroundContainer

- (UIView *)loadingBackgroundContainerView
{
    return self.loadingBackgroundContainer;
}

@end
