//
//  VRemixSelectViewController.h
//  victorious
//
//  Created by Gary Philipp on 4/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractVideoEditorViewController.h"

@interface VRemixSelectViewController : VAbstractVideoEditorViewController

+ (UIViewController *)remixViewControllerWithURL:(NSURL *)url sequenceID:(NSInteger)sequenceID nodeID:(NSInteger)nodeID;

@end
