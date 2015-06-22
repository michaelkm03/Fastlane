//
//  VUsersDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPageType.h"
#import "VHasManagedDependencies.h"

/**
 An object that loads and provides an array of users to be displayed in a view
 that requires a VUserDataSource.
 */
@protocol VUsersDataSource <NSObject>

/**
 Asks the adoptor of this protocol to load its data and call completion when
 loading is complete.
 */
- (void)refreshWithPageType:(VPageType)pageType completion:(void(^)(BOOL success, NSError *error))completion;

/**
 Provides all of the currently loaded users that should be displayed.  This array
 is read during initialization, when loading data with `refreshWithPageType:completion:`
 is complete, and any other time that the view is refreshed.
 */
- (NSArray *)users;

/**
 The title to be displayed in a no content view when the data source returns
 no results.
 */
- (NSString *)noContentTitle;

/**
 The longer, more detailed message to be displayed in a no content view when
 the data source returns no results.
 */
- (NSString *)noContentMessage;

/**
 An image to accompany the `noContentTitle` and `noContentMessage` text when
 the data source returns no results.
 */
- (UIImage *)noContentImage;

@end
