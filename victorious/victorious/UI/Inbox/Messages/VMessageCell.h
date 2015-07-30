//
//  VMessageCell.h
//  victorious
//
//  Created by Will Long on 5/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessageTextAndMediaView.h"

@class VDefaultProfileImageView, VMessage;

extern NSString * const kVMessageCellNibName;

@interface VMessageCell : UITableViewCell

@property (nonatomic, weak, readonly) IBOutlet VMessageTextAndMediaView  *messageTextAndMediaView;
@property (nonatomic, weak, readonly) IBOutlet UILabel                   *timeLabel;
@property (nonatomic, weak, readonly) IBOutlet VDefaultProfileImageView  *profileImageView;
@property (nonatomic, copy)                    void                     (^onProfileImageTapped)();
@property (nonatomic)                          BOOL                       profileImageOnRight; ///< If YES, the profile image is to the right of the chat bubble

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width message:(VMessage *)message;

@end
