//
//  VCommentCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VCommentCell.h"

#import "VComment.h"
#import "UIImageView+AFNetworking.h"
#import "VConstants.h"

@implementation VCommentCell

- (void)configureCellForComment:(VComment*)comment
{
    self.dataSource = comment;
    
    self.textLabel.text = comment.text;

    if ([comment.mediaType isEqualToString:VConstantsMediaTypeImage])
    {   //TODO: this should be the profile image
        [self.imageView setImageWithURL:[NSURL URLWithString: (NSString*)comment.mediaUrl]                        placeholderImage: [UIImage imageNamed:@"avatar.jpg"]];
    }
}

@end
