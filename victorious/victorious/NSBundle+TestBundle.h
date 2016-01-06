//
//  NSBundle+TestBundle.h
//  victorious
//
//  Created by Patrick Lynch on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (TestBundle)

/**
 Determines whether app launch should be interupted to prevent the entire initialization
 experience including template download, login, etc.
 */
@property (nonatomic, readonly, assign) BOOL v_shouldCompleteLaunch;

/**
 Loads the injected test bundle ("XCInjectBundle") if present, otherwise returns nil.
 */
+ (nullable NSBundle *)v_testBundle;

@end

NS_ASSUME_NONNULL_END
