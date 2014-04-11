//
//  VCameraPublishViewController.h
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@interface VCameraPublishViewController : UIViewController

@property (nonatomic, strong)   UIImage*    previewImage;
@property (nonatomic, strong)   NSURL*      mediaURL;
@property (nonatomic, strong)   NSString*   mediaExtension;

@property (nonatomic)           BOOL          useTwitter;
@property (nonatomic)           BOOL          useFacebook;

@property (nonatomic, weak) IBOutlet    UITextView*     textView;

@property (nonatomic, strong)   NSString*     expirationDateString;

/**
 This block will be called when the user has finished publishing
 
 @param completed YES if the user chose to publish, NO if the 
                      user cancelled or an error occurred.
 */
@property (nonatomic, copy) void (^completion)(BOOL completed);

+ (VCameraPublishViewController *)cameraPublishViewController;

@end
