//
//  VStreamYoutubeVideoCell.m
//  victorious
//
//  Created by Will Long on 2/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamYoutubeVideoCell.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

@interface VStreamYoutubeVideoCell() <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton* playButton;
@property (weak, nonatomic) IBOutlet UIImageView* playButtonImage;
@end

@implementation VStreamYoutubeVideoCell

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    self.webView.hidden = YES;
    self.playButton.userInteractionEnabled = YES;
    self.playButtonImage.hidden = NO;
}

- (IBAction)presssedPlay:(id)sender
{
    NSString* videoID = [[self.sequence firstNode] firstAsset].data;
    
    self.webView.scrollView.scrollEnabled = NO;
    
    [self.webView setAllowsInlineMediaPlayback:YES];
    [self.webView setMediaPlaybackRequiresUserAction:NO];
    
    NSString* embedHTML = [NSString stringWithFormat:@"\
                           <html>\
                           <body style='margin:0px;padding:0px;'>\
                           <script type='text/javascript' src='http://www.youtube.com/iframe_api'></script>\
                           <script type='text/javascript'>\
                           function onYouTubeIframeAPIReady()\
                           {\
                           ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})\
                           }\
                           function onPlayerReady(a)\
                           { \
                           a.target.playVideo(); \
                           }\
                           </script>\
                           <iframe id='playerId' type='text/html' width='%f' height='%f' src='http://www.youtube.com/embed/%@?enablejsapi=1&rel=0&playsinline=1&autoplay=0' frameborder='0'>\
                           </body>\
                           </html>",
                           self.webView.frame.size.width,
                           self.webView.frame.size.height,
                           videoID];
    
    [self.webView loadHTMLString:embedHTML baseURL:[[NSBundle mainBundle] resourceURL]];
    self.playButton.userInteractionEnabled = NO;
    self.playButtonImage.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webView.hidden = NO;
}

@end
