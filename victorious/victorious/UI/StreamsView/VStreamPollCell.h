//
//  VStreamPollCell.h
//  victoriOS
//
//  Created by Will Long on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStreamViewCell.h"
#import "VBadgeLabel.h"

static NSString *kStreamDoublePollCellIdentifier = @"VStreamDoublePollCell";

@interface VStreamPollCell : VStreamViewCell

@property (weak, nonatomic) IBOutlet UIImageView* previewImageTwo;

@end
