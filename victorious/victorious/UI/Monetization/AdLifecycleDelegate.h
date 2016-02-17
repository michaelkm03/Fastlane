//
//  AdLifecycleDelegate.h
//  victorious
//
//  Created by Alex Tamoykin on 2/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// Defines callbacks for different stages of ad playback
@protocol AdLifecycleDelegate <NSObject>

@required

- (void)adDidLoad;
- (void)adDidFinish;
- (void)adDidStart;
- (void)adHadError:(NSError *)error;

@end
