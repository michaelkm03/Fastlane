//
//  VStreamCollectionCellAnnouncement.m
//  victorious
//
//  Created by Patrick Lynch on 11/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCellAnnouncement.h"
#import "VWebContentViewController.h"
#import "VThemeManager.h"

@interface VStreamCollectionCellAnnouncement()

@property (nonatomic, strong) VWebContentViewController *webContentViewController;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation VStreamCollectionCellAnnouncement

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIColor *backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.backgroundColor = backgroundColor;
    
    self.webContentViewController = [[VWebContentViewController alloc] initWithWebView:self.webView];
    self.webContentViewController.webView.backgroundColor = backgroundColor;
}

- (void)loadAnnouncementUrl:(NSString *)urlString forceReload:(BOOL)shouldForceReload
{
    if ( shouldForceReload || (self.webContentViewController.urlToView == nil && !shouldForceReload) )
    {
        self.webContentViewController.urlToView = [NSURL URLWithString:urlString];
    }
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
}

@end
