//
//  VCreatorMessageViewController.m
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreatorMessageViewController.h"
#import "VDependencyManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "VAppInfo.h"

NSString * const VCreatorMessageTextKey = @"creatorMessage";

@interface VCreatorMessageViewController()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UILabel *creatorNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *creatorAvatarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *quoteImageView;
@property (nonatomic, weak) IBOutlet UITextView *messageTextView;

@property (nonatomic, assign) CGFloat defaultMessageViewHeight;
@property (nonatomic, assign) CGFloat defaulBoundsHeight;

@end

@implementation VCreatorMessageViewController

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *nibName = NSStringFromClass([self class]);
    self = [super initWithNibName:nibName bundle:bundle];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.defaultMessageViewHeight = CGRectGetHeight(self.messageTextView.bounds);
    self.defaulBoundsHeight = CGRectGetHeight(self.view.bounds);
    
    [self applyStyle];
    
    [self updateMessage];
}

- (void)updateMessage
{
    if ( self.dependencyManager == nil )
    {
        return;
    }
    
    NSAssert( self.dependencyManager != nil, @"VCreatorMessageViewController must have a dependency manager before setting message." );
    NSDictionary *attributes = [self stringAttributesWithFont:[self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey]
                                                        color:[self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey]
                                                   lineHeight:23.0f];
    NSString *message = [self.dependencyManager stringForKey:VCreatorMessageTextKey];
    self.messageTextView.attributedText = [[NSAttributedString alloc] initWithString:message attributes:attributes];
    
    [self updateBounds];
}

- (void)updateBounds
{
    CGRect bounds = self.view.bounds;
    bounds.size.height = self.defaulBoundsHeight + CGRectGetHeight(self.messageTextView.bounds) - self.defaultMessageViewHeight;
    if ( self.creatorAvatarImageView.hidden )
    {
        bounds.size.height -= CGRectGetHeight(self.creatorAvatarImageView.frame);
    }
    self.view.bounds = bounds;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    [self applyStyle];
}

- (void)applyStyle
{
    if ( self.dependencyManager == nil )
    {
        return;
    }
    
    VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:self.dependencyManager];
    NSString *ownerName = appInfo.ownerName;
    NSURL *profileImageURL = appInfo.profileImageURL;
    
    BOOL stringIsValid = [self stringIsValidForDisplay:ownerName];
    BOOL profileImageURLIsEmpty = [profileImageURL.absoluteString isEqualToString:@""];
    if ( !stringIsValid || profileImageURLIsEmpty )
    {
        // If there's no valid data to show for this creator, hide these views
        self.creatorNameLabel.hidden = YES;
        self.creatorAvatarImageView.hidden = YES;
        
        [self updateBounds];
    }
    else
    {
        self.creatorNameLabel.hidden = NO;
        self.creatorAvatarImageView.hidden = NO;
        
        self.quoteImageView.image = [self.quoteImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.quoteImageView.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        
        self.creatorNameLabel.text = ownerName;
        self.creatorNameLabel.textColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryTextColorKey];
        self.creatorNameLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
        
        self.creatorAvatarImageView.layer.cornerRadius = CGRectGetWidth(self.creatorAvatarImageView.bounds) * 0.5f; // Enough to make it a circle
        self.creatorAvatarImageView.layer.borderWidth = 1.0f;
        self.creatorAvatarImageView.layer.borderColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey].CGColor;
        self.creatorAvatarImageView.layer.masksToBounds = YES;
        
        [self.creatorAvatarImageView sd_setImageWithURL:profileImageURL placeholderImage:nil];
    }
}

- (BOOL)stringIsValidForDisplay:(NSString *)string
{
    return string != nil && ![string isEqualToString:@""];
}

- (NSDictionary *)stringAttributesWithFont:(UIFont *)font color:(UIColor *)color lineHeight:(CGFloat)lineHeight
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = lineHeight;
    
    return @{ NSFontAttributeName: font ?: [NSNull null],
              NSForegroundColorAttributeName: color,
              NSParagraphStyleAttributeName: paragraphStyle };
}

@end
