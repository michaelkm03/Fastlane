//
//  OpenXMSDK.h
//  OpenX_iOS_SDK
//
//  Created by Oleg Kovtun on 06.12.11.
//  Copyright (c) 2011 OpenX. All rights reserved.
//

#import <Availability.h>

#ifndef __IPHONE_5_0
#warning "OpenX SDK uses features only available in iOS SDK 5.0 and later."
#endif

#ifndef __IPHONE_7_0
#warning "It is recommended to use at least iOS SDK 7.0 with OpenX SDK"
#endif

/* Basic ad banner (wrapper above ad banner controller) */
#import "OXMAdBanner.h"

/* OpenX ad controllers and the request */
#import "OXMAdBannerController.h"
#import "OXMAdBannerView.h"
#import "OXMAdInterstitialController.h"
#import "OXMAdRequest.h"
#import "OXMNativeAds.h"
#import "OXMNativeAdRequest.h"
#import "OXMNativeAdData.h"

/* VAST (Video) */
#import "OXMMediaPlaybackView.h"
#import "OXMVideoAdManager.h"

/* console debugging information */
#import "OXMConsole.h"
#import "OXMErrors.h"

#import "OXMFunctions.h"

