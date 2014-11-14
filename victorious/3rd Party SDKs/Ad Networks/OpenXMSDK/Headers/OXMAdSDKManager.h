//
//  AdSDKManager.h
//  MobPubAdapter
//
//  Created by Jon Flanders on 6/5/14.
//  Copyright (c) 2014 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OXMStopWatch.h"
#import "OXMAdSDKAdapter.h"

@protocol OXMAdSDKManagerDelegate <NSObject>
-(void)onAdDidLoad:(NSString*)adapter;
-(void)onAdDisplayed:(NSString*)adapter;
-(void)onAdFailedToLoad:(NSString*)adapter withError:(NSError*)error;
-(void)onAdClosed:(NSString*)adapter;
-(void)onAdClicked:(NSString*)adapter;
@end

@interface OXMAdSDKManager : NSObject<AdSDKAdapterDelegate>
@property (nonatomic,assign) id<OXMAdSDKManagerDelegate> delegate;
- (void)fillAdWithAdUnit:(NSString *)genericAdUnitID andType:(NSString *)adType forDomain:(NSString*)domain andCallback:(void (^)(UIView *, id<OXMAdSDKAdapter>,NSError * error))callback;
@end
