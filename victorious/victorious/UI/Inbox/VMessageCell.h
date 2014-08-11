//
//  VMessageCell.h
//  victorious
//
//  Created by Will Long on 5/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VCommentTextAndMediaView;

extern NSString * const kVMessageCellNibName;

@interface VMessageCell : UITableViewCell

@property (nonatomic, weak, readonly) IBOutlet VCommentTextAndMediaView  *commentTextView;
@property (nonatomic, weak, readonly) IBOutlet UILabel                   *timeLabel;
@property (nonatomic, weak, readonly) IBOutlet UIImageView               *profileImageView;
@property (nonatomic, copy)                    void                     (^onProfileImageTapped)();
@property (nonatomic)                          BOOL                       profileImageOnRight; ///< If YES, the profile image is to the right of the chat bubble

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text withMedia:(BOOL)hasMedia;

@end
