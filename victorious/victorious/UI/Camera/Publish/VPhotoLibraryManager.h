//
//  VPhotoLibraryManager.h
//  victorious
//
//  Created by Josh Hinman on 10/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VPhotoLibraryManagerCompletionBlock)(NSError *error);

extern const NSInteger VPhotoLibraryManagerIncompatibleVideoErrorCode; ///< The video was not able to be saved because it is incompatible with photo library
extern const NSInteger VPhotoLibraryManagerUnknownAssetTypeErrorCode; ///< The media was not able to be saved because its type could not be determined
extern NSString * const VPhotoLibraryManagerErrorDomain;

@class ALAssetsLibrary;

/**
 Provides a nicer façade for ALAssetsManager
 */
@interface VPhotoLibraryManager : NSObject

/**
 An instance of ALAssetsLibrary. This property
 is really only here for unit testing purposes.
 If it's not set, a suitable default is used.
 */
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

/**
 Saves a photo or video to the user's photo library
 */
- (void)saveMediaAtURL:(NSURL *)media toPhotoLibraryWithCompletion:(VPhotoLibraryManagerCompletionBlock)completion;

@end
