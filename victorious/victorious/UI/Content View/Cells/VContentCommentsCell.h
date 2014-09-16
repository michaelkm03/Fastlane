//
//  VContentCommentsCell.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

//Subviews
#import "VCommentTextAndMediaView.h"

@interface VContentCommentsCell : VBaseCollectionViewCell

+ (CGSize)sizeWithCommentBody:(NSString *)commentBody;

@property (nonatomic, strong) NSURL *URLForCommenterAvatar;
@property (nonatomic, strong) NSString *commenterName;
@property (nonatomic, strong) NSString *timestampText;
@property (nonatomic, strong) NSString *realTimeCommentText;
@property (nonatomic, weak, readonly) VCommentTextAndMediaView *commentAndTextMediaView;

@end
