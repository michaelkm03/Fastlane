//
//  VFirstTimeInstallHelper.m
//  victorious
//
//  Created by Lawrence Leach on 3/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFirstTimeInstallHelper.h"
#import "VSequence+Fetcher.h"
#import "VObjectManager+Sequence.h"
#import "VAsset+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VDependencyManager.h"

static NSString * const VDidPlayFirstTimeUserVideo = @"com.getvictorious.settings.didPlayFirstTimeUserVideo";
NSString * const kFTUSequenceURLPath = @"sequenceUrlPath";

@interface VFirstTimeInstallHelper ()

@end

@implementation VFirstTimeInstallHelper

+ (instancetype)sharedInstance
{
    static  VFirstTimeInstallHelper  *sharedInstance;
    static  dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
                  ^{
                      sharedInstance = [[self alloc] init];
                      
                  });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

#pragma mark - Accessors

- (BOOL)hasBeenShown
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:VDidPlayFirstTimeUserVideo] boolValue];
}

- (BOOL)hasMediaUrl
{
    if (self.mediaUrl != nil)
    {
        return YES;
    }
    return NO;
}

#pragma mark - Dependency Manager Setter

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    
    if (_dependencyManager != nil)
    {
        [self fetchMediaSequenceObject];
    }
}

#pragma mark - Select media sequence

- (void)fetchMediaSequenceObject
{
    NSString *sequenceId = [[self.dependencyManager stringForKey:kFTUSequenceURLPath] lastPathComponent];
    [[VObjectManager sharedManager] fetchSequenceByID:sequenceId
                                         successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         self.sequence = (VSequence *)resultObjects.firstObject;
         VNode *node = (VNode *)[self.sequence firstNode];
         VAsset *asset = [node mp4Asset];
         if (asset.dataURL != nil)
         {
             self.mediaUrl = asset.dataURL;
         }
         else
         {
             self.mediaUrl = nil;
         }

     }
                                            failBlock:^(NSOperation *operation, NSError *error)
     {
         self.mediaUrl = nil;
     }];
}

#pragma mark - Save to NSUserDefaults

- (void)savePlaybackDefaults
{
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:VDidPlayFirstTimeUserVideo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
