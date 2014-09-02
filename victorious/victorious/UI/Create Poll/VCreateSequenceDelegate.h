//
//  VCreateSequenceDelegate.h
//  victorious
//
//  Created by David Keegan on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@protocol VCreateSequenceDelegate <NSObject>

@optional
- (void)createPollWithQuestion:(NSString *)question
                   answer1Text:(NSString *)answer1Text
                   answer2Text:(NSString *)answer2Text
                     media1URL:(NSURL *)media1Data
                     media2URL:(NSURL *)media2Data;

@end