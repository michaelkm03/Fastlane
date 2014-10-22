//
//  VVideoCellViewModel.h
//  victorious
//
//  Created by Michael Sena on 10/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VAdSystem)
{
    VAdSystemNone = 0,
    VAdSystemOpenX = 1,
    VAdSystemLiveRail = 2,
};

@interface VVideoCellViewModel : NSObject

+ (instancetype)videoCelViewModelWithItemURL:(NSURL *)itemURL andAdSystem:(VAdSystem)adSystem;

@property (nonatomic, readonly) NSURL *itemURL;
@property (nonatomic, readonly) VAdSystem adSystem;

@end
