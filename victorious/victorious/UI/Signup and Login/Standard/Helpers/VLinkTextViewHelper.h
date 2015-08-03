//
//  VLinkTextViewHelper.h
//  victorious
//
//  Created by Patrick Lynch on 2/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <Foundation/Foundation.h>

@class CCHLinkTextView;

@interface VLinkTextViewHelper : NSObject <VHasManagedDependencies>

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

- (void)setupLinkTextView:(CCHLinkTextView *)linkTextView withText:(NSString *)text range:(NSRange)range;

@end
