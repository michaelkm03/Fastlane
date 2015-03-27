//
//  VContentPollCell.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

typedef void (^VAnswerSelectionBlock)(BOOL isVideo, NSURL *mediaURL);

/**
 *  A UICollectionViewCell for displaying poll content.
 */
@interface VContentPollCell : VBaseCollectionViewCell

@property (nonatomic) NSString *numberOfVotersText;

@property (nonatomic, copy) NSURL *answerAThumbnailMediaURL;
@property (nonatomic, copy) NSURL *answerBThumbnailMediaURL;

@property (nonatomic, assign) BOOL answerAIsFavored;
@property (nonatomic, assign) BOOL answerBIsFavored;

@property (nonatomic, readonly) BOOL answerBIsVideo;
@property (nonatomic, readonly) BOOL answerAIsVideo;

@property (nonatomic, readonly) UIImage *answerAPreviewImage;
@property (nonatomic, readonly) UIImage *answerBPreviewImage;

@property (nonatomic, weak, readonly) UIView *answerAContainer;
@property (nonatomic, weak, readonly) UIView *answerBContainer;

@property (nonatomic, copy) VAnswerSelectionBlock onAnswerASelection;
@property (nonatomic, copy) VAnswerSelectionBlock onAnswerBSelection;

- (void)setAnswerAPercentage:(CGFloat)answerAPercentage
                    animated:(BOOL)animated;

- (void)setAnswerBPercentage:(CGFloat)answerBPercentage
                    animated:(BOOL)animated;

- (void)setAnswerAIsVideowithVideoURL:(NSURL *)videoURL;

- (void)setAnswerBIsVideowithVideoURL:(NSURL *)videoURL;

@end
