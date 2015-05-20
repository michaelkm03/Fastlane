//
//  VCoachmark.h
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"

@class VBackground;

typedef NS_ENUM( NSUInteger, VToastLocation )
{
    VToastLocationTop,
    VToastLocationMiddle,
    VToastLocationBottom,
    VToastLocationInvalid
};

@interface VCoachmark : NSObject <VHasManagedDependencies, NSCoding>

@property (nonatomic, strong) NSString *currentScreenText;
@property (nonatomic, strong) NSString *relatedScreenText;
@property (nonatomic, strong) NSString *displayTarget;
@property (nonatomic, strong) NSArray *displayScreens;
@property (nonatomic, strong) VBackground *background;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) VToastLocation toastLocation;
@property (nonatomic, strong) NSString *remoteId;
@property (nonatomic, assign) BOOL hasBeenShown;

@end
