//
//  VEditProfilePicturePresenter.h
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractPresenter.h"

/**
 *  A completion block for the edit profile picture presenter.
 */
typedef void(^VEditProfilePictureCompletion)(BOOL success, UIImage *previewImage, NSURL *mediaURL);

/**
 *  Presents the edit profile picture interface.
 */
@interface VEditProfilePicturePresenter : VAbstractPresenter

/**
 *  Setting this to YES allows the camera to show a contextual permission dialog pre-prompting the user.
 */
@property (nonatomic, assign) BOOL isRegistration;

/**
 *  A completion block for the presenter. Be sure to retain this presenter if providing a completion block.
 */
@property (nonatomic, copy) VEditProfilePictureCompletion completion;

@end
