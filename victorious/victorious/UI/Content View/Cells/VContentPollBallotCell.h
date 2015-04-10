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

+ (CGSize)actualSizeWithAnswerA:(NSAttributedString *)answerA
                        answerB:(NSAttributedString *)answerB
                    maximumSize:(CGSize)maximumSize;

- (void)setVotingDisabledWithFavoredBallot:(VBallot)ballot
                                  animated:(BOOL)animated;

@property (nonatomic, copy) NSAttributedString *answerA;
@property (nonatomic, copy) NSAttributedString *answerB;

@property (nonatomic, copy) void (^answerASelectionHandler)(void);
@property (nonatomic, copy) void (^answerBSelectionHandler)(void);

@property (nonatomic, weak) IBOutlet UIImageView *orImageView;

@end
