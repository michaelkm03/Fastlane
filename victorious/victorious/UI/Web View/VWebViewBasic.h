//
//  VWebViewBasic.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VWebViewProtocol.h"

@interface VWebViewBasic : NSObject <VWebViewProtocol>

@property (nonatomic, strong) id<VWebViewDelegate> delegate;

@end
