//
//  VStreamViewCell.h
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VSequence;

static NSString *kStreamViewCellIdentifier = @"StreamViewCell";

extern NSString *kStreamsWillSegueNotification;

@interface VStreamViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) VSequence* sequence;

// TODO: for some reason if these are not here the cell does not show up
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;

@end
