//
//  VCreateSequenceDelegate.h
//  victorious
//
//  Created by David Keegan on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@protocol VCreateSequenceDelegate <NSObject>

@optional
- (void)createPostwithMessage:(NSString *)message
                         data:(NSData *)data
                    mediaType:(NSString *)mediaType;

- (void)createPollWithQuestion:(NSString *)question
                   answer1Text:(NSString *)answer1Text
                   answer2Text:(NSString *)answer2Text
                    media1URL:(NSURL *)media1Data
               media1Extension:(NSString *)media1Extension
                    media2URL:(NSURL *)media2Data
               media2Extension:(NSString *)media2Extension;

@end