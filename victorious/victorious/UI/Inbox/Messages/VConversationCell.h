//
//  VConversationCell.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTableViewCell.h"
#import "VCellWithProfileDelegate.h"

extern const CGFloat VConversationCellHeight;

@class VConversation, VDependencyManager;

NS_ASSUME_NONNULL_BEGIN

@interface VConversationCell : UITableViewCell

@property (nonatomic, strong, nullable) VConversation *conversation;
@property (nonatomic, weak, nullable) UITableViewController *parentTableViewController;
@property (nonatomic, strong, nullable) VDependencyManager *dependencyManager;

+ (NSString *)suggestedReuseIdentifier;

@property (nonatomic, strong, nullable) id<VCellWithProfileDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
