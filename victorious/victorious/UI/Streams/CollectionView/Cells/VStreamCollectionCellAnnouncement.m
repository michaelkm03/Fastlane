//
//  VStreamCollectionCellAnnouncement.m
//  victorious
//
//  Created by Patrick Lynch on 11/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCellAnnouncement.h"
#import "VWebViewDelegate.h"
#import "VThemeManager.h"

@interface VStreamCollectionCellAnnouncement()

@property (nonatomic, strong) VWebViewDelegate *webViewDelegate;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURL *url;

@end

@implementation VStreamCollectionCellAnnouncement

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIColor *backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    self.backgroundColor = backgroundColor;
    
    self.webViewDelegate = [[VWebViewDelegate alloc] init];
    self.webView.delegate = self.webViewDelegate;
    self.webView.backgroundColor = backgroundColor;
}

- (void)loadAnnouncementUrl:(NSString *)urlString forceReload:(BOOL)shouldForceReload
{
    if ( shouldForceReload || (self.url == nil && !shouldForceReload) )
    {
        [self.webViewDelegate loadUrlString:urlString withWebView:self.webView];
    }
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
}

@end
