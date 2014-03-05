//
//  VContentViewController.h
//  victorious
//
//  Created by Will Long on 2/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSequence;

extern CGFloat kContentMediaViewOffset;

@interface VContentViewController : UIViewController

@property (strong, nonatomic) VSequence* sequence;
@property (weak, nonatomic) IBOutlet UIView* mediaView;

+ (VContentViewController *)sharedInstance;

@end
