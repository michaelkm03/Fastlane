//
//  OXMNativeAdData.h
//  OpenX_iOS_SDK
//
//
//

#import <Foundation/Foundation.h>

@protocol OXMNativeAdDelegate;

@interface OXMNativeAdData : NSObject

@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) NSString* imgurl;
@property (nonatomic, readonly) NSString* objectstoreurl;
@property (nonatomic, readonly) NSString* body;
@property (nonatomic, readonly) NSString* actorname;
@property (nonatomic, readonly) NSString* actorimage;
@property (nonatomic, readonly) NSString* videourl;
@property (nonatomic, readonly) NSString* audiourl;
@property (nonatomic, strong)NSString* domain;

@property (nonatomic, weak) NSObject <OXMNativeAdDelegate>* nativeAdDelegate;

/** Method to call once a native ad has been viewed in order to record the impression.
 */
-(void) adWasViewed;

/** Method to call when a native ad has been tapped in order to record the tap-thru.
 */
-(void) adWasTapped;


/** Method to call when logging a native ad.
 */
-(void)logEventWithKey:(NSString*)key andValue:(NSString*)val;


/** Method to call when logging a native ad.
 */
-(void)logEventWithKey:(NSString*)key;


/** Retrieve the raw JSON object
 */
-(NSString*)rawJSON;

@end

@protocol OXMNativeAdDelegate <NSObject>
@optional
/** This delegate method is called AFTER a native ad impression has been recorded.
 */
-(void)nativeAdWasViewed;


/** This delegate method is called AFTER a native ad has been tapped.
 */
-(void)nativeAdWasTapped;


@end
