//
//  VContentCommentsCell.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@interface VContentCommentsCell : VBaseCollectionViewCell

+ (CGSize)sizeWithFullWidth:(CGFloat)width
                commentBody:(NSString *)commentBody
                andHasMedia:(BOOL)hasMedia;

@property (nonatomic, copy) NSURL *URLForCommenterAvatar;
@property (nonatomic, copy) NSString *commenterName;
@property (nonatomic, copy) NSString *timestampText;
@property (nonatomic, copy) NSString *realTimeCommentText;

// Comment Configuration
@property (nonatomic, copy) NSString *commentBody;
@property (nonatomic, assign) BOOL hasMedia;
@property (nonatomic, copy) NSURL *mediaPreviewURL;
@property (nonatomic, assign) BOOL mediaIsVideo;

@end
