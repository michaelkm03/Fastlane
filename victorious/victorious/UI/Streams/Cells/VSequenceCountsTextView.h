//
//  VSequenceCountsTextView.h
//  victorious
//
//  Created by Patrick Lynch on 6/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCHLinkTextView.h>

/**
 Delegate for VSequenceCountsTextView designed to let calling code know when
 either the "Likers" or "Comments" section of the text has been selected.
 */
@protocol VSequenceCountsTextViewDelegate <NSObject>

/**
 "Likers" text selected.
 */
- (void)likersTextSelected;

/**
 "Comments" text selected.
 */
- (void)commentsTextSelected;

@end

/**
 A text view that displays comment and liker counts, handling all of the completed
 attributes string and tappable text configuration internally.
 */
@interface VSequenceCountsTextView : CCHLinkTextView

/**
 Updates the text with the number of likes.
 */
- (void)setLikesCount:(NSInteger)likesCount;

/**
 Updates the text with the number of comments.
 */
- (void)setCommentsCount:(NSInteger)commentsCount;

/**
 Returns whether the counts provided were displayed according to the internal logic.
 */
+ (BOOL)canDisplayTextWithCommentCount:(NSInteger)commentCount likesCount:(NSInteger)likesCount;

/**
 Delegate that is notified when the user interacts with the text view.
 */
@property (nonatomic, weak) id<VSequenceCountsTextViewDelegate> textSelectionDelegate;

/**
 Determines where the comments count can show according to permissions, regarless of its value.
 */
@property (nonatomic, assign) BOOL hideComments;

/**
 Determines where the likes count can show according to permissions, regarless of its value.
 */
@property (nonatomic, assign) BOOL hideLikes;

@property (nonatomic, strong) NSDictionary *textAttributes;

@property (nonatomic, strong) NSDictionary *linkAttributes;

@end
