//
//  VVideoCellViewModel.h
//  victorious
//
//  Created by Michael Sena on 10/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VEndCardModel.h"

/**
 Enumeration of supported ad networks
 */
typedef NS_ENUM(NSInteger, VMonetizationPartner)
{
    /**
     No ad network present
     */
    VMonetizationPartnerNone     = 0,
    /**
     LiveRail
     */
    VMonetizationPartnerLiveRail = 1,
    /**
     OpenX
     */
    VMonetizationPartnerOpenX    = 2,
    /**
     Tremor Video
     */
    VMonetizationPartnerTremor   = 3
};


@interface VVideoCellViewModel : NSObject

/**
 Factory method to setup video cell's view model with content and monetization information
 
 @param itemURL             Content URL
 @param monetizationPartner Enum value of choosen ad network
 @param details             NSArray of ad details
 
 @return An instance of the video cell view model
 */
+ (instancetype)videoCellViewModelWithItemURL:(NSURL *)itemURL
                                 withAdSystem:(VMonetizationPartner)monetizationPartner
                                  withDetails:(NSArray *)details
                                     withLoop:(BOOL)loop;

/**
 Content URL
 */
@property (nonatomic, readonly) NSURL *itemURL;

/**
 Content URL
 */
@property (nonatomic, assign, readonly) BOOL loop;

/**
 Enum value of the selected ad network
 */
@property (nonatomic, readonly) VMonetizationPartner monetizationPartner;

/**
 NSArray that contains all of the ad details
 */
@property (nonatomic, readonly) NSArray *monetizationDetails;

/**
 All the data necessary to display and populate the end card
 after a video has finished playing.  If this is `nil`, then there is
 no end card for this video and it should not be displayed.
 */
@property (nonatomic, strong, readwrite) VEndCardModel *endCardViewModel;

@end
