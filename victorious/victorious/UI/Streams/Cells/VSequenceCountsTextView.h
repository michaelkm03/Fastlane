//
//  VSequenceCountsTextView.h
//  victorious
//
//  Created by Patrick Lynch on 6/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCHLinkTextView.h>
#import "VHasManagedDependencies.h"

@protocol VSequenceCountsTextViewDelegate <NSObject>

- (void)likersTextSelected;

- (void)commentsTextSelected;

@end

@interface VSequenceCountsTextView : CCHLinkTextView <VHasManagedDependencies>

- (void)setLikesCount:(NSInteger)likesCount;

- (void)setCommentsCount:(NSInteger)commentsCount;

@property (nonatomic, weak) id<VSequenceCountsTextViewDelegate> textSelectionDelegate;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
