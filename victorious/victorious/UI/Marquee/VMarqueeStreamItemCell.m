//
//  VMarqueeStreamItemCell.m
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMarqueeStreamItemCell.h"

#import "VDefaultProfileButton.h"

#import "VStreamItem+Fetcher.h"
#import "VSequence+Fetcher.h"
#import "VUser.h"

#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+ImageCreation.h"

#import "VThemeManager.h"
#import "VSettingManager.h"
#import "VStreamWebViewController.h"
#import "UIVIew+AutoLayout.h"

@interface VMarqueeStreamItemCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, weak) IBOutlet UIImageView *previewImageView;
@property (nonatomic, weak) IBOutlet UIImageView *pollOrImageView;
@property (nonatomic, weak) IBOutlet UIView *webViewContainer;
@property (nonatomic, weak) IBOutlet UIView *detailsContainer;
@property (nonatomic, weak) IBOutlet UIView *detailsBackgroundView;
@property (nonatomic, strong) VStreamWebViewController *webViewController;

@property (nonatomic, weak) IBOutlet VDefaultProfileButton *profileImageButton;

@property (nonatomic, strong) NSTimer *hideTimer;

@end

static CGFloat const kVCellHeightRatio = 0.884375; //from spec, 283 height for 360 width

@implementation VMarqueeStreamItemCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.profileImageButton.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor].CGColor;
    self.profileImageButton.layer.borderWidth = 4;
    
    NSString *textColorKey = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled] ? kVLinkColor : kVMainTextColor;
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:textColorKey];
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    
    self.detailsContainer.alpha = 0.0;
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    
    self.nameLabel.text = streamItem.name;
    
    NSURL *previewImageUrl = [NSURL URLWithString: [streamItem.previewImagePaths firstObject]];
    [self.previewImageView fadeInImageAtURL:previewImageUrl
                           placeholderImage:[UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];
    
    self.detailsBackgroundView.backgroundColor = [[VThemeManager sharedThemeManager] preferredBackgroundColor];
    
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        VSequence *sequence = (VSequence *)streamItem;
        
        self.pollOrImageView.hidden = ![sequence isPoll];
        
        [self.profileImageButton setProfileImageURL:[NSURL URLWithString:sequence.user.pictureUrl]
                                           forState:UIControlStateNormal];
        self.profileImageButton.hidden = [[VSettingManager sharedManager] settingEnabledForKey:VSettingsTemplateCEnabled];
        
        if ( [sequence isWebContent] )
        {
            [self setupWebViewWithSequence:sequence];
        }
        else
        {
            [self cleanupWebView];
        }
    }
    else
    {
        self.profileImageButton.hidden = YES;
    }
    
    [self makeDetailsContainerVisible:YES animated:NO];
    [self.hideTimer invalidate];
    self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f
                                                      target:self
                                                    selector:@selector(hideDetailContainer)
                                                    userInfo:nil
                                                     repeats:NO];
}

- (void)makeDetailsContainerVisible:(BOOL)visible animated:(BOOL)animated
{
    CGFloat targetAlpha = visible ? 1.0 : 0.0;
    
    if ( animated )
    {
        [UIView animateWithDuration:0.5f animations:^{
            
            self.detailsContainer.alpha = targetAlpha;
            
        }];
    }
    else
    {
        self.detailsContainer.alpha = targetAlpha;
    }
}

- (void)cleanupWebView
{
    if ( self.webViewController != nil )
    {
        [self.webViewController.view removeFromSuperview];
        self.webViewController = nil;
        self.previewImageView.hidden = NO;
    }
}

- (void)setupWebViewWithSequence:(VSequence *)sequence
{
    if ( self.webViewController == nil )
    {
        self.webViewController = [[VStreamWebViewController alloc] init];
        [self.webViewContainer addSubview:self.webViewController.view];
        [self.webViewContainer v_addFitToParentConstraintsToSubview:self.webViewController.view];
        self.previewImageView.hidden = YES;
    }
    
    NSString *contentUrl = (NSString *)sequence.previewData;
    [self.webViewController setUrl:[NSURL URLWithString:contentUrl]];
}

- (void)hideDetailContainer
{
    [self makeDetailsContainerVisible:NO animated:YES];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.streamItem = nil;
    [self makeDetailsContainerVisible:YES animated:NO];
}

- (IBAction)userSelected:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(cell:selectedUser:)])
    {
        [self.delegate cell:self selectedUser:((VSequence *)self.streamItem).user];
    }
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = width * kVCellHeightRatio;
    return CGSizeMake(width, height);
}

@end
