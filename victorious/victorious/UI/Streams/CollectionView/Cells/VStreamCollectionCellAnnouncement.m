//
//  VStreamCollectionCellAnnouncement.m
//  victorious
//
//  Created by Patrick Lynch on 11/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCellAnnouncement.h"
#import "VThemeManager.h"

@interface VStreamCollectionCellAnnouncement() <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURL *url;

@end

@implementation VStreamCollectionCellAnnouncement

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIColor *backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.backgroundColor = backgroundColor;
    
    self.webView.delegate = self;
    self.webView.backgroundColor = backgroundColor;
}

- (void)loadAnnouncementUrl:(NSString *)urlString forceReload:(BOOL)shouldForceReload
{
    if ( shouldForceReload || (self.url == nil && !shouldForceReload) )
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    }
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
}

@end
