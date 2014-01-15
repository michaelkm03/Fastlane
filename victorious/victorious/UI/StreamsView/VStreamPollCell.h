//
//  VStreamPollCell.h
//  victoriOS
//
//  Created by Will Long on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStreamViewCell.h"
#import "VInboxBadgeLabel.h"

static NSString *kStreamPollCellIdentifier = @"VStreamPollCell";
static NSString *kStreamDoublePollCellIdentifier = @"VStreamDoublePollCell";

@interface VStreamPollCell : VStreamViewCell

@property (weak, nonatomic) IBOutlet UIButton* optionOneButton;
@property (weak, nonatomic) IBOutlet UIButton* optionTwoButton;

@property (weak, nonatomic) IBOutlet UIButton* playOneButton;
@property (weak, nonatomic) IBOutlet UIButton* playTwoButton;

@property (weak, nonatomic) IBOutlet UIImageView* previewImageTwo;

@property (weak, nonatomic) IBOutlet UIView* answerView;

@property (weak, nonatomic) IBOutlet VInboxBadgeLabel* firstResultLabel;
@property (weak, nonatomic) IBOutlet VInboxBadgeLabel* secondResultLabel;

- (IBAction)pressedOptionOne:(id)sender;
- (IBAction)pressedOptionTwo:(id)sender;

@end
