//
//  AdSDKAdapter.h
//  
//
//  Created by Jon Flanders on 6/5/14.
//  Copyright (c) 2014 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OXMAdSDKChoice.h"


static NSString* OXM_AD_TYPE_BANNER = @"Banner";
static NSString* OXM_AD_TYPE_INTERSTITIAL = @"Interstitial";
static NSString* OXM_TRANSACTION_STATE_KEY = @"ts";
static NSString* OXM_TRACKING_URL_TEMPLATE = @"record_tmpl";
static NSString* OXM_ORIGINAL_ADUNIT_KEY = @"OriginalAdUnitID";
static NSString* OXM_MEDIATION_URL = @"mediation_url";
@protocol AdSDKAdapterDelegate;

@protocol OXMAdSDKAdapter 
@property (nonatomic,assign)id<AdSDKAdapterDelegate> delegate;
@property (nonatomic,readonly) NSString* adapterName;
@property BOOL adapterSucceeded;
-(void)adSDKAdapterCreateViewFromChoice:(OXMAdSDKChoice*)adChoice;
-(void)adSDKDoPostAddSubViewOperations:(UIView*)view;
@end

@protocol AdSDKAdapterDelegate
-(void)adSDKAdapterFailedToLoadAd:(id<OXMAdSDKAdapter>)adapter;
-(void)adSDKAdapterLoadedAdView:(UIView*)adView fromAdapter:(id<OXMAdSDKAdapter>)adapter;
-(void)adSDKAdapterLoadedAd:(id<OXMAdSDKAdapter>)adapter;
-(void)adSDKAdapterDisplayed:(id<OXMAdSDKAdapter>)adapter;
-(void)adSDKAdapterAdClosed:(NSString*)adapter;
-(void)adSDKAdapterAdClicked:(NSString*)adapter;
@end