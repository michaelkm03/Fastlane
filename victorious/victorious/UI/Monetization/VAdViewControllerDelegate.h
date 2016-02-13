//
//  VAdViewControllerDelegate.h
//  victorious
//
//  Created by Alex Tamoykin on 2/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@protocol VAdViewControllerDelegate <NSObject>

@required

- (void)adDidLoad;
- (void)adDidFinish;

@optional

- (void)adDidStartPlayback;
- (void)adDidStopPlaybackIn;
- (void)adHadImpression;
- (void)adHadError:(NSError *)error;
- (void)adDidHitFirstQuartile;
- (void)adDidHitMidpoint;
- (void)adDidHitThirdQuartile;

@end
