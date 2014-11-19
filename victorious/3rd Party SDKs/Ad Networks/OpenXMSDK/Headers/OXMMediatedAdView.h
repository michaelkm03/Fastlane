//
//  MediatedAdView.h
//  MobPubAdapter
//
//  Created by Jon Flanders on 6/4/14.
//  Copyright (c) 2014 OpenX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol OXMMediatedAdViewDelegate <NSObject>
@optional
-(void)onAdDidLoad:(NSString*)adapter;
-(void)onAdDisplayed:(NSString*)adapter;
-(void)onAdFailedToLoad:(NSString*)adapter withError:(NSError*)error;
-(void)onAdClosed:(NSString*)adapter;
-(void)onAdClicked:(NSString*)adapter;
@end

@interface OXMMediatedAdView : UIView
@property (nonatomic,assign) id<OXMMediatedAdViewDelegate> delegate;
@property (nonatomic,strong) NSString* adUnit;
@property (nonatomic,strong) NSString* domain;
@property (nonatomic,strong) NSString* adType;
-(void)show;
-(void)startLoading;
@end
