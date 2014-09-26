//
//  VStreamViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCreatePollViewController.h"
#import "VAnimation.h"

@class VStreamTableDataSource, VStream, VSequence, VStreamViewCell;

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

@protocol VStreamCommentDelegate <NSObject>
@required

- (void)willCommentOnSequence:(id)sequenceObject;

@end

@interface VStreamTableViewController : UITableViewController <VAnimation, VCreateSequenceDelegate>

@property (nonatomic)         VStreamFilter    filterType;
@property (nonatomic, strong) VStream *currentStream;
@property (nonatomic, readonly) VStream *defaultStream;

@property (nonatomic, strong, readonly) VStreamTableDataSource *tableDataSource;
@property (nonatomic, strong) VSequence *selectedSequence;
@property (nonatomic, strong) NSArray *repositionedCells;;
@property (nonatomic, weak) id<VStreamTableDelegate, UITableViewDelegate> delegate;
@property (nonatomic, weak) id<VStreamCommentDelegate> commentDelegate;
@property (nonatomic, readonly) NSString *viewName; ///< The view name that will be sent to the analytics server, can be overridden by subclasses
@property (nonatomic, strong) NSString *hashTag;

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
