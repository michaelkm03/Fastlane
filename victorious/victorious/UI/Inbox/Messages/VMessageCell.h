//
//  VMessageCell.h
//  victorious
//
//  Created by Will Long on 5/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMessageTextAndMediaView.h"
#import "VFocusable.h"
#import "VCellWithProfileDelegate.h"

@class VDefaultProfileImageView, VMessage;

extern NSString * const kVMessageCellNibName;

@interface VMessageCell : UITableViewCell <VFocusable>

@property (nonatomic, weak, readonly) IBOutlet VMessageTextAndMediaView *messageTextAndMediaView;
@property (nonatomic, weak, readonly) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) id<VCellWithProfileDelegate> profileDelegate;
@property (nonatomic) BOOL profileImageOnRight; ///< If YES, the profile image is to the right of the chat bubble

+ (NSString *)suggestedReuseIdentifier;

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width message:(VMessage *)message;

@end
