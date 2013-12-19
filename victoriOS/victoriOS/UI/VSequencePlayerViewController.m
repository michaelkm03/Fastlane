//
//  VSequencePlayerViewController.m
//  victoriOS
//
//  Created by Will Long on 12/18/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VSequencePlayerViewController.h"

#import "VNode.h"
#import "VAsset+Fetcher.h"
#import "VInteraction+Fetcher.h"
#import "VNode+Fetcher.h"
#import "UIImageView+AFNetworking.h"

@import MediaPlayer;

@interface VSequencePlayerViewController ()

@property (nonatomic, strong) MPMoviePlayerController* mpController;
@property (nonatomic, weak) VNode* currentNode;

@end

@implementation VSequencePlayerViewController

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    [self loadNode:[[VNode orderedNodesForSequence:_sequence] firstObject]];
}

- (instancetype)initWithSequence:(VSequence*)sequence
{
    self = [super initWithNibName:@"VSequencePlayerViewController" bundle:[NSBundle mainBundle]];
    if (self)
    {
        _mpController = [[MPMoviePlayerController alloc] initWithContentURL:nil];
        [self.view addSubview:_mpController.view];
        self.sequence = sequence;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goToNextNode
{
    //TODO: replace with next node logic.
    [self loadNode:_currentNode];
}

static NSString *youTubeVideoHTML = @"<iframe width=\"%@\" height=\"%@\" src=\"//www.youtube.com/embed/%@\" frameborder=\"0\" allowfullscreen></iframe>";

- (void)loadNode:(VNode*)node
{
    NSArray* assets = [VAsset orderedAssetsForNode:node];
    VAsset* currentAsset = [assets firstObject];
    if (YES || [currentAsset.type isEqualToString:@"youtube_video_url"])
    {
        _imageView.hidden = YES;
        _mpController.view.hidden = YES;
        _webView.hidden = NO;
        
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
                               _webView.frame.size.width,
                               _webView.frame.size.height,
//                               currentAsset.data];
                               @"aHjpOzsQ9YI"];

        [_webView loadHTMLString:embedHTML baseURL:[[NSBundle mainBundle] resourceURL]];
    }
    else if ([currentAsset.type isEqualToString:@"video_url"])
    {
        _imageView.hidden = YES;
        _webView.hidden = YES;
        _mpController.view.hidden = NO;
        [_mpController setContentURL:[NSURL URLWithString:currentAsset.data]];
    }
    else if ([currentAsset.type isEqualToString:@"image_url"] ||
             [currentAsset.type isEqualToString:@"url"])
    {
        _mpController.view.hidden = YES;
        _webView.hidden = YES;
        _imageView.hidden = NO;
        [_imageView setImageWithURL:[NSURL URLWithString:currentAsset.data]];
    }
    else if (!currentAsset) //This means its a Poll
    {
        //poll logic
    }
    
    [self readyInteractionsForNode:node];
}

- (void)readyInteractionsForNode:(VNode*)node
{
    for (VInteraction* interaction in [VInteraction orderedInteractionsForNode:node])
    {
//        __block VInteraction* savedInteraction = interaction;
        NSTimeInterval delay = NSTimeIntervalSince1970 + ([interaction.startTime integerValue]/ 1000);
        [self performSelector:@selector(launchInteraction:) withObject:interaction afterDelay:delay];
    }
}

- (void)launchInteraction:(VInteraction*)interaction
{
    //TODO: Replace the alert with actual interaction logic.
    UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"There is an interaction here! " message:@"This functionality is not implemented" delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
    [alert show];
}

@end
