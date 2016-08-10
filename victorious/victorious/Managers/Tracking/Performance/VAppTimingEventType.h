//
//  VAppTimingEventType.h
//  victorious
//
//  Created by Patrick Lynch on 12/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

@import Foundation;

/**
 Cosntants in this file are intended for use with a `TimingTracker` object,
 and represent the available values that can be used for the `type` and `subtype`
 parameters through the `TimingTracker` interface.
 */

/**
 From app launch until landing page presented and stream loaded; Applies to returning users only; new users will see registration page.
 */
extern NSString * const VAppTimingEventTypeAppStart;

/**
 From app launch until registration presented.
 Applies to new users only; returning users bypass registration page
 */
extern NSString * const VAppTimingEventTypeShowRegistration;

/**
 From signup method selected until registration complete.
 Captures how quickly a new user progresses through registration.
 */
extern NSString * const VAppTimingEventTypeSignup;

/**
 FromLogin method selected until landing page presented.
 */
extern NSString * const VAppTimingEventTypeLogin;

/**
 From stream load requested until stream content is rendered.
 Captures time taken to load a stream endpoint completely
 */
extern NSString * const VAppTimingEventTypeStreamLoad;

/**
 From stream cell selected from stream until all related requests finished.
 This includes the combined duration of potentially many endpoints,
 i.e. sequence fetch, poll results, sequence interactions, etc.
 */
extern NSString * const VAppTimingEventTypeContentViewLoad;

/**
 From user refreshes the page until stream content is rendered.
 This is the same as stream_load, except it is for any requests sent after the first time.
 */
extern NSString * const VAppTimingEventTypeStreamRefresh;

extern NSString * const VAppTimingEventSubtypeEmail;
extern NSString * const VAppTimingEventSubtypeFacebook;
