//
//  VWebViewAdvanced.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebViewProtocol.h"

@import UIKit;
@import WebKit;

@interface VWebViewAdvanced : NSObject <VWebViewProtocol>

@property (nonatomic, weak) id<VWebViewDelegate> delegate;

@end
