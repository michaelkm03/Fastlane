//
//  VPublishPresenter.h
//  victorious
//
//  Created by Michael Sena on 7/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractPresenter.h"

@class VPublishParameters;
@class VPublishViewController;

@interface VPublishPresenter : VAbstractPresenter

/** These properties are wrappers for the presenter and forwarded to the publishViewController internally.
 *  See "VPublishViewController.h" for their documentation.
 */
@property (nonatomic, copy) void (^completion)(BOOL published); // The presenter will handle dismissal
@property (nonatomic, strong) VPublishParameters *publishParameters;

@end
