//
//  VLoginType.h
//  victorious
//
//  Created by Patrick Lynch on 5/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import Foundation;

/**
 The possible login types for a session.
 */
typedef NS_ENUM( NSInteger, VLoginType )
{
    VLoginTypeNone,         ///< Default value, usually means there is currently no logged in session
    VLoginTypeEmail,        ///< User signed up with email and password
    VLoginTypeFaceBook,     ///< User connected with their Facebook account
    VLoginTypeTwitter,      ///< User connected with their Twitter account
    VLoginTypeCount,
};