//
//  VCaptureVideoPreviewView.h
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@class VCaptureVideoPreviewView;

@protocol VCaptureVideoPreviewViewDelegate <NSObject>

/**
 *  Informs the delegate about taps on the previewView and converts them to 
 *  captureDevice coordinates.
 */
- (void)captureVideoPreviewView:(VCaptureVideoPreviewView *)previewView
                 tappedLocation:(CGPoint)locationInCaptureDeviceCoordinates;

/**
 *  Queries the delegate about whether or not it should display the focus reticle
 *  when the user taps on the previewView. Return YES to show, NO to prevent the
 *  reticle from showing.
 */
- (BOOL)shouldShowTapsForVideoPreviewView:(VCaptureVideoPreviewView *)previewView;

@end

/**
 *  A View wrapper around AVCapturePreviewLayer. Displays a reticle and informs 
 *  its delegate about taps relative to the current capture device.
 */
@interface VCaptureVideoPreviewView : UIView

/**
 *  A delegate to be informed about previewView events.
 */
@property (nonatomic, weak) IBOutlet id <VCaptureVideoPreviewViewDelegate> delegate;

/**
 *  Forwarded to the internal previewLayer.
 */
@property (strong) AVCaptureSession *session;

/**
 *  Forwarded to the internal previewLayer.
 */
@property (copy) NSString *videoGravity;

@end
