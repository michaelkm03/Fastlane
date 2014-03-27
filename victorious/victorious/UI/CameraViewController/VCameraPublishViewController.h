//
//  VCameraPublishViewController.h
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@interface VCameraPublishViewController : UIViewController

@property (nonatomic, strong)   UIImage*    photo;
@property (nonatomic, strong)   NSURL*      videoURL;

@property (nonatomic)           BOOL          useTwitter;
@property (nonatomic)           BOOL          useFacebook;

@property (nonatomic, weak) IBOutlet    UITextView*     textView;

@property (nonatomic, strong)   NSString*     expirationDateString;

@end
