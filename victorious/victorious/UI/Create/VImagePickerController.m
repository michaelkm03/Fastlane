//
//  VImagePickerController.m
//  victorious
//
//  Created by Will Long on 1/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VImagePickerController.h"

#import "VConstants.h"

@implementation VImagePickerController

- (id)init
{
    self = [super init];
    if (self)
    {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            self.sourceType = UIImagePickerControllerSourceTypeCamera;
        else
            self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        self.allowsEditing = YES;
        
        self.videoMaximumDuration = 10.0f;
    }
    return self;
}

- (void)setType:(VImagePickerControllerType)type
{
    if (self.type == VImagePickerControllerTypePhoto)
        self.mediaTypes = @[(NSString *)kUTTypeImage];
    
    else if (self.type == VImagePickerControllerTypeVideo)
        self.mediaTypes = @[(NSString *)kUTTypeMovie];
    
    else //default to all media types
        self.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
}

@end
