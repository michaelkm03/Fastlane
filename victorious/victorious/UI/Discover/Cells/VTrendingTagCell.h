//
//  VTrendingTagCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VFollowHashtagControl.h"

@class VHashtag;

@interface VTrendingTagCell : UITableViewCell

/**
 Block to execute upon tapping on the subscribe / unsubscribe button
 */
@property (nonatomic, copy) void (^subscribeToTagAction)(void);

/**
 Reports if the hashtag to be presented has been subscribed to
 */
@property (nonatomic, readonly) BOOL subscribedToTag;

/**
 Flag for the view controller to specify if the subscribe / unsubscribe button should be animated when tapped
 */
@property (nonatomic, assign) BOOL shouldAnimateSubscription;

/**
 The control for the subscribe / unsubscribe button
 */
@property (nonatomic, weak) IBOutlet VFollowHashtagControl *followHashtagControl;

/**
 The actual text of the hashtag (minus the #)
 */
@property (nonatomic, strong) NSString *hashtagText;

@property (nonatomic, assign) BOOL shouldCellRespond;

/**
 Returns an integer value for the height of the cell
 
 @return NSInteger value for the cell height
 */
+ (NSInteger)cellHeight;

/**
 Hashtag setter
 
 @param hashtag The VHashtag object to present for this cell
 */
- (void)setHashtag:(VHashtag *)hashtag;

/**
 Checks to see if hashtag is subscribed to or not and animates the subscribe button accordingly.
 
 @param animate BOOL to tell the control to animate it's changing state
 */
- (void)updateSubscribeStatusAnimated:(BOOL)animated;

@end
