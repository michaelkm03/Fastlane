//
//  VStreamViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCreatePollViewController.h"
#import "VAnimation.h"

@class VStreamTableDataSource, VStream, VSequence;

typedef NS_ENUM(NSInteger, VStreamFilter)
{
    VStreamFilterFeatured,
    VStreamFilterRecent,
    VStreamFilterFollowing,
};

@protocol VStreamTableDelegate <NSObject>
@optional
- (void)streamWillDisappear;
@end

@interface VStreamTableViewController : UITableViewController <VAnimation>

@property (nonatomic)         VStreamFilter    filterType;
@property (nonatomic, strong) VStream *currentStream;
@property (nonatomic, readonly) VStream* defaultStream;

@property (strong, nonatomic, readonly) VStreamTableDataSource* tableDataSource;
@property (strong, nonatomic) VSequence* selectedSequence;
@property (strong, nonatomic) NSArray* repositionedCells;;
@property (weak, nonatomic) id<VStreamTableDelegate, UITableViewDelegate> delegate;
@property (nonatomic, readonly) NSString *viewName; ///< The view name that will be sent to the analytics server, can be overridden by subclasses

/**
 *  No content image/title/message to be used when there is no content to display for a given filter. Does not update. Desired properties must be set before ViewWilAppear could be called.
 */
@property (nonatomic, strong) UIImage *noContentImage;
@property (nonatomic, strong) NSString *noContentTitle;
@property (nonatomic, strong) NSString *noContentMessage;

- (void)refreshWithCompletion:(void(^)(void))completionBlock;

+ (instancetype)homeStream;
+ (instancetype)communityStream;
+ (instancetype)ownerStream;
+ (instancetype)hashtagStreamWithHashtag:(NSString *)hashtag;

+ (instancetype)streamWithDefaultStream:(VStream *)stream name:(NSString *)name title:(NSString *)title;

@end
