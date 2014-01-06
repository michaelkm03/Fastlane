//
//  VStreamPollCell.h
//  victoriOS
//
//  Created by Will Long on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStreamViewCell.h"

static NSString *kStreamPollCellIdentifier = @"StreamPollCell";
static NSString *kStreamDoublePollCellIdentifier = @"StreamDoublePollCell";

@interface VStreamPollCell : VStreamViewCell

@property (weak, nonatomic) IBOutlet UIButton* optionOneButton;
@property (weak, nonatomic) IBOutlet UIButton* optionTwoButton;

@property (weak, nonatomic) IBOutlet UIImageView* previewImageTwo;

- (IBAction)pressedOptionOne:(id)sender;
- (IBAction)pressedOptionTwo:(id)sender;

@end
