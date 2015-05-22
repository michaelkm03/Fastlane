//
//  VTracking.h
//  victorious
//
//  Created by Patrick Lynch on 10/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VSequence, VVoteType;

@interface VTracking : NSManagedObject

@property (nonatomic, retain) id cellClick;
@property (nonatomic, retain) id cellView;
@property (nonatomic, retain) id videoComplete25;
@property (nonatomic, retain) id videoComplete50;
@property (nonatomic, retain) id videoComplete75;
@property (nonatomic, retain) id videoComplete100;
@property (nonatomic, retain) id videoError;
@property (nonatomic, retain) id videoSkip;
@property (nonatomic, retain) id videoStall;
@property (nonatomic, retain) id viewStart;
@property (nonatomic, retain) id ballisticCount;
@property (nonatomic, retain) id appEnterForeground;
@property (nonatomic, retain) id appLaunch;
@property (nonatomic, retain) id appInstall;
@property (nonatomic, retain) id appEnterBackground;
@property (nonatomic, retain) id share;

@property (nonatomic, retain) id createProfileStart;
@property (nonatomic, retain) id firstBoot;
@property (nonatomic, retain) id registrationEnd;
@property (nonatomic, retain) id registrationStart;
@property (nonatomic, retain) id getStartedTap;
@property (nonatomic, retain) id doneButtonTap;
@property (nonatomic, retain) id registeRbuttonTap;
@property (nonatomic, retain) id signUpButtonTap;
@property (nonatomic, retain) id welcomeVideoStart;
@property (nonatomic, retain) id welcomeVideoEnd;
@property (nonatomic, retain) id welcomeStart;

@property (nonatomic, retain) VSequence *sequence;
@property (nonatomic, retain) VVoteType *voteType;

@end
