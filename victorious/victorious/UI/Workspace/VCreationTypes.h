//
//  VCreationTypes.h
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
#warning Merge this wtih other content type enums?
typedef NS_ENUM(NSInteger, VCreationType)
{
    VCreationTypeImage,
    VCreationTypeVideo,
    VCreationTypePoll,
    VCreationTypeText,
    VCreationTypeGIF,
    VCreationTypeUnknown
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
};

#endif
