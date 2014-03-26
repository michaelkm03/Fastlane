//
//  VRemixPublishViewController.m
//  victorious
//
//  Created by Gary Philipp on 3/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VRemixPublishViewController.h"
#import "VObjectManager+Sequence.h"
#import "VConstants.h"

@interface VRemixPublishViewController ()
@end

@implementation VRemixPublishViewController

- (IBAction)publish:(id)sender
{
    VLog (@"Publishing");
    
    VShareOptions shareOptions = self.useFacebook ? kVShareToFacebook : kVShareNone;
    shareOptions = self.useTwitter ? shareOptions | kVShareToTwitter : shareOptions;
    
    NSData* mediaData;
    NSString* mediaType;
    if (self.videoURL)
    {
        mediaData = [NSData dataWithContentsOfURL:self.videoURL];
        mediaType = VConstantMediaExtensionMOV;
    }
    else if (self.photo)
    {
        mediaData = UIImagePNGRepresentation(self.photo);
        mediaType = VConstantMediaExtensionPNG;
    }
    else
    {
        return;
    }
    
//    @property (nonatomic)                   BOOL                    muteAudio;
//    @property (nonatomic)                   RemixPlaybackSpeed      playBackSpeed;
//    @property (nonatomic)                   CGFloat                 startSeconds;
//    @property (nonatomic)                   CGFloat                 endSeconds;

    [[VObjectManager sharedManager] uploadMediaWithName:self.textView.text
                                            description:self.textView.text
                                              expiresAt:self.expirationDateString
                                           parentNodeId:nil
                                               loopType:self.playbackLooping
                                           shareOptions:shareOptions
                                              mediaData:mediaData
                                              extension:mediaType
                                               mediaUrl:nil
                                           successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         VLog(@"Succeeded with objects: %@", resultObjects);
     }
                                              failBlock:^(NSOperation* operation, NSError* error)
     {
         VLog(@"Failed with error: %@", error);
     }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
