//
//  VVideoCellViewModel.h
//  victorious
//
//  Created by Michael Sena on 10/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VConstants.h"

@interface VVideoCellViewModel : NSObject

/**
 Factory method to setup video cell's view model with content and monetization information
 
 @param itemURL             Content URL
 @param monetizationPartner Enum value of choosen ad network
 @param details             NSArray of ad details
 
 @return An instance of the video cell view model
 */
+ (instancetype)videoCellViewModelWithItemURL:(NSURL *)itemURL withAdSystem:(VMonetizationPartner)monetizationPartner withDetails:(NSArray *)details;

/**
 Content URL
 */
@property (nonatomic, readonly) NSURL *itemURL;

/**
 Enum value of the selected ad network
 */
@property (nonatomic, readonly) VMonetizationPartner monetizationPartner;

/**
 NSArray that contains all of the ad details
 */
@property (nonatomic, readonly) NSArray *monetizationDetails;

@end
