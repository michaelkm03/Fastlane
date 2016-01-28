//
//  VHashtagCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VHashtag, VFollowControl, VDependencyManager;

@interface VHashtagCell : UITableViewCell

/**
 Block to execute upon tapping on the subscribe / unsubscribe button
 */
@property (nonatomic, copy) void (^onToggleFollowHashtag)(void);

/**
 The control for the subscribe / unsubscribe button
 */
@property (nonatomic, weak) IBOutlet VFollowControl *followHashtagControl;

/**
 Hashtag property to format
 */
@property (nonatomic, strong) NSString *hashtagText;

/**
 Set this to adjust font, font color, and background color
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 Returns an integer value for the height of the cell
 
 @return NSInteger value for the cell height
 */
+ (NSInteger)cellHeight;

+ (NSString *)suggestedReuseIdentifier;

@end
