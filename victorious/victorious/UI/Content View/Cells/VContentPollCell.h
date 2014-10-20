//
//  VContentPollCell.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

/**
 *  A UICollectionViewCell for displaying poll content.
 */
@interface VContentPollCell : VBaseCollectionViewCell

@property (nonatomic, copy) NSURL *answerAThumbnailMediaURL;
@property (nonatomic, assign) BOOL answerAIsVideo;
@property (nonatomic, copy) NSURL *answerBThumbnailMediaURL;
@property (nonatomic, assign) BOOL answerBIsVideo;

@end
