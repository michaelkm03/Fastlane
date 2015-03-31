//
//  VCrossFadingLabel.h
//  victorious
//
//  Created by Sharif Ahmed on 3/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCrossFadingView.h"

@interface VCrossFadingLabel : UILabel <VCrossFadingView>

- (void)setupWithStrings:(NSArray *)strings andTextAttributes:(NSDictionary *)textAttributes;

@property (nonatomic, readonly) NSArray *strings;
@property (nonatomic, strong) NSDictionary *textAttributes;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) BOOL opaqueOutsideArrayRange;

@end
