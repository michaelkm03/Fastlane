//
//  VNotification.m
//  victorious
//
//  Created by Lawrence Leach on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotification.h"
#import "VComment.h"
#import "VMessage.h"
#import "VUser.h"

/*
 {
 "id":"23703",
 "display_order":3,
 "subject":"P Dizzle Isle posted a new poll!",
 "body":"P Dizzle Isle posted a new poll!",
 "deeplink":"dev-braindex:\/\/content\/12304",
 "type":"follow_post",
 "creator_profile_image_url":"http:\/\/media-dev-public.s3-website-us-west-1.amazonaws.com\/29a1e9ba45c9651ac78891e477d0bf73\/80x80.jpg",
 "media_preview_image_url":"http:\/\/media-dev-public.s3-website-us-west-1.amazonaws.com\/6db41fc373ce44d65378ef8bbeb2dfb6.jpg",
 "is_read":"no",
 "created_at":"2015-03-24 01:29:10",
 "updated_at":"2015-03-24 01:29:10"
 },
 
 */

@implementation VNotification

@dynamic body;
@dynamic deeplink;
@dynamic isRead;
@dynamic notifyType;
@dynamic postedAt;
@dynamic remoteId;
@dynamic subject;
@dynamic userId;
@dynamic imageURL;
@dynamic createdAt;

@dynamic user;
@dynamic message;
@dynamic comment;

@end
