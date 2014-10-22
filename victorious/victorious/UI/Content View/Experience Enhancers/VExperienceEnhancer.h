//
//  VExperienceEnhancer.h
//  victorious
//
//  Created by Michael Sena on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VVoteType;

@interface VExperienceEnhancer : NSObject

- (instancetype)initWithVoteType:(VVoteType *)voteType;

@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) NSString *labelText;
@property (nonatomic, strong) NSArray *animationSequence;
@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) NSTimeInterval flightDuration;
@property (nonatomic, strong) UIImage *flightImage;
@property (nonatomic, assign) BOOL shouldLetterBox;

@property (nonatomic, readonly) VVoteType *voteType;
@property (nonatomic, readonly) BOOL hasRequiredImages;
@property (nonatomic, readonly) BOOL isBallistic;

@end
