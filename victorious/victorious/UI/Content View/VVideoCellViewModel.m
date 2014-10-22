//
//  VVideoCellViewModel.m
//  victorious
//
//  Created by Michael Sena on 10/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VVideoCellViewModel.h"

@interface VVideoCellViewModel ()

@property (nonatomic, strong, readwrite) NSURL *itemURL;
@property (nonatomic, assign, readwrite) VAdSystem adSystem;

@end

@implementation VVideoCellViewModel

+ (instancetype)videoCelViewModelWithItemURL:(NSURL *)itemURL
                                 andAdSystem:(VAdSystem)adSystem
{
    if (![itemURL isKindOfClass:[NSURL class]])
    {
        return nil;
    }
    
    VVideoCellViewModel *videoCellViewModel = [[VVideoCellViewModel alloc] init];
    videoCellViewModel.itemURL = itemURL;
    videoCellViewModel.adSystem = adSystem;
    
    return videoCellViewModel;
}

@end
