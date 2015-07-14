//
//  VMediaAttachmentPresenter.h
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractPresenter.h"

typedef NS_OPTIONS(NSUInteger, VMediaAttachmentType)
{
    VMediaAttachmentTypeImage   = 1 << 0,
    VMediaAttachmentTypeVideo   = 1 << 1,
};

/**
 *  A completion block for the media attachment presenter.
 */
typedef void(^VMediaAttachmentCompletion)(BOOL success, UIImage *previewImage, NSURL *mediaURL);

/**
 *  A presenter for attaching media to various parts of the app.
 */
@interface VMediaAttachmentPresenter : VAbstractPresenter

/**
 *  A completion block for the presenter. Be sure to retain this presenter if providing a completion block.
 */
@property (nonatomic, copy) VMediaAttachmentCompletion completion;

/**
 *  A bitmask determining which types of attachments are available. Defaults to Image | Video | GIF.
 */
@property (nonatomic, assign) VMediaAttachmentType attachmentTypes;

@end
