//
//  VVideoCellViewModel.h
//  victorious
//
//  Created by Michael Sena on 10/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VMonetizationPartner)
{
    VMonetizationPartnerNone     = 0,
    VMonetizationPartnerLiveRail = 1,
    VMonetizationPartnerOpenX    = 2,
};

@interface VVideoCellViewModel : NSObject

+ (instancetype)videoCelViewModelWithItemURL:(NSURL *)itemURL withAdSystem:(VMonetizationPartner)monetizationPartner withOptions:(NSDictionary *)options;

@property (nonatomic, readonly) NSURL *itemURL;
@property (nonatomic, readonly) VMonetizationPartner monetizationPartner;
@property (nonatomic, readonly) NSDictionary *monetizationOptions;

@end
