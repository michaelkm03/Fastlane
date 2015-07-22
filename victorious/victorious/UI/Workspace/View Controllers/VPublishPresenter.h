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

/**
 *  These properties are wrappers for the presenter and forwarded to the publishViewController internally.
 *  See "VPublishViewController.h" for their documentation.
 *  
 *  Publish Presenter does not dismiss the publish screen.
 */
@property (nonatomic, copy) void (^publishActionHandler)(BOOL published);

/**
 *  Provide publishing with some publish parameters.
 */
@property (nonatomic, strong) VPublishParameters *publishParameters;

@end
