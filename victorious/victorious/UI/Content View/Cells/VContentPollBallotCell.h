//
//  VContentPollBallotCell.h
//  victorious
//
//  Created by Michael Sena on 10/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

typedef NS_ENUM(NSInteger, VBallot)
{
    VBallotA,
    VBallotB
};

@interface VContentPollBallotCell : VBaseCollectionViewCell

- (void)setVotingDisabledWithFavoredBallot:(VBallot)ballot
                                  animated:(BOOL)animated;

@property (nonatomic, copy) NSString *answerA;
@property (nonatomic, copy) NSString *answerB;

@property (nonatomic, copy) void (^answerASelectionHandler)(void);
@property (nonatomic, copy) void (^answerBSelectionHandler)(void);

@property (nonatomic, weak) IBOutlet UIImageView *orImageView;

@end
