//
//  VPurchaseViewController.h
//  victorious
//
//  Created by Patrick Lynch on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVoteType+Fetcher.h"

@interface VPurchaseViewController : UIViewController

+ (VPurchaseViewController *)instantiateFromStoryboard:(NSString *)storyboardName withVoteType:(VVoteType *)voteType;

@property (nonatomic, strong) VVoteType *voteType;

@end
