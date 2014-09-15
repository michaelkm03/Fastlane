//
//  VContentCommentsCell.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@interface VContentCommentsCell : VBaseCollectionViewCell

+ (CGSize)sizeWithCommentBody:(NSString *)commentBody;

@property (weak, nonatomic) IBOutlet UIImageView *commentersAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentersUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *realtimeCommentLocationLabel;
@property (weak, nonatomic) IBOutlet UITextView *commentBodyTextView;

@end
