//
//  VCreationFlowTypes.h
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#ifndef victorious_VCreationTypes_h
#define victorious_VCreationTypes_h

/**
 *  The creaiton types that the app is prepared to handle.
 */
typedef NS_ENUM(NSInteger, VCreationFlowType)
{
    VCreationFlowTypeImage,
    VCreationFlowTypeVideo,
    VCreationFlowTypePoll,
    VCreationFlowTypeText,
    VCreationFlowTypeGIF,
    VCreationFlowTypeSticker,
    VCreationFlowTypeLibrary,
    VCreationFlowTypeMixedMediaCamera,
    VCreationFlowTypeNativeCamera,
    VCreationFlowTypeUnknown
};

/**
 * The various contexts that camera, library, and microphone permissions may be requested under.
 */
typedef NS_ENUM(NSInteger, VCameraContext)
{
    VCameraContextProfileImage,
    VCameraContextProfileImageRegistration,
    VCameraContextImageContentCreation,
    VCameraContextVideoContentCreation,
    VCameraContextMixedMediaContentCreation
};

#endif
