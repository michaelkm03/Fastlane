//
//  VCanvasView.h
//  victorious
//
//  Created by Michael Sena on 12/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VPhotoFilter.h"

@interface VCanvasView : UIView

@property (nonatomic, strong) UIImage *sourceImage;

@property (nonatomic, strong) VPhotoFilter *filter;

@property (nonatomic, readonly) UIScrollView *canvasScrollView;

@end
