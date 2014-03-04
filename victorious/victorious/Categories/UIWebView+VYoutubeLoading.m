//
//  UIWebView+VYoutubeLoading.m
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIWebView+VYoutubeLoading.h"

@implementation UIWebView (VYoutubeLoading)

- (void)loadWithYoutubeID:(NSString*)videoID
{
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
                           <iframe id='playerId' type='text/html' width='%f' height='%f' src='http://www.youtube.com/embed/%@?enablejsapi=1&rel=0&playsinline=1&autoplay=1' frameborder='0'>\
                           </body>\
                           </html>",
                           self.frame.size.width,
                           self.frame.size.height,
                           videoID];
    
    [self loadHTMLString:embedHTML baseURL:[[NSBundle mainBundle] resourceURL]];
}
    
@end
