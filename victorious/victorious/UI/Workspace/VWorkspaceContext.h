//
//  VWorkspaceContext.h
//  victorious
//
//  Created by Steven F Petteruti on 6/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

/*
 * Shared enum type because a few different classes use it
 */

// The context in which we're opening the workspace
typedef NS_ENUM(NSInteger, VWorkspaceFlowControllerContext)
{
    VWorkspaceFlowControllerContextProfileImage,
    VWorkspaceFlowControllerContextProfileImageRegistration,
    VWorkspaceFlowControllerContextContentCreation,
};
