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

@implementation VStreamYoutubeVideoCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    [self setYoutubeVideo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(streamsWillSegue:)
                                                 name:kStreamsWillSegueNotification
                                               object:nil];
    
    self.webView.scrollView.scrollEnabled = NO;
}


- (void)setYoutubeVideo
{
    NSString* videoID = [[self.sequence firstNode] firstAsset].data;
    
    self.webView.hidden = NO;
    
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
                           </script>\
                           <iframe id='playerId' type='text/html' width='%f' height='%f' src='http://www.youtube.com/embed/%@?enablejsapi=1&rel=0&playsinline=1&autoplay=0' frameborder='0'>\
                           </body>\
                           </html>",
                           self.webView.frame.size.width,
                           self.webView.frame.size.height,
                           videoID];
    
    [self.webView loadHTMLString:embedHTML baseURL:[[NSBundle mainBundle] resourceURL]];
}

- (void)streamsWillSegue:(NSNotification *) notification
{
    //TODO: remove hack.  This should pause the video instead of resetting it.
    [self setYoutubeVideo];
}

@end
