//
//  VMediaAttachmentPresenter.h
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractPresenter.h"
#import "VPublishParameters.h"

typedef NS_OPTIONS(NSUInteger, VMediaAttachmentOptions)
{
    VMediaAttachmentOptionsImage   = 1 << 0,
    VMediaAttachmentOptionsVideo   = 1 << 1,
    VMediaAttachmentOptionsGIF     = 1 << 2,
};

NS_ASSUME_NONNULL_BEGIN

/**
 *  A completion block for the media attachment presenter.
 */
typedef void(^VMediaAttachmentResultHandler)(BOOL success, VPublishParameters *__nullable publishParameters);

/**
 *  A presenter for attaching media to various parts of the app. NOTE: When there are two ore more attachment types this 
 *  presenter will first present an action sheet then the appropriate flow. If there is a single attachment type, then no 
 *  action sheet will be show and we move straight to capturing an attachmet.
 */
@interface VMediaAttachmentPresenter : VAbstractPresenter

/**
 *  An extra initializer to inject extra dependencies into the dependency tree.
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
                        addedDependencies:(NSDictionary *)addedDependencies;

/**
 *  A completion block for the presenter. Be sure to retain this presenter if providing a completion block.
 */
@property (nonatomic, copy) VMediaAttachmentResultHandler resultHandler;

/**
 *  A bitmask determining which types of attachments are available. Defaults to Image | Video.
 */
@property (nonatomic, assign) VMediaAttachmentOptions attachmentTypes;

@end

NS_ASSUME_NONNULL_END
