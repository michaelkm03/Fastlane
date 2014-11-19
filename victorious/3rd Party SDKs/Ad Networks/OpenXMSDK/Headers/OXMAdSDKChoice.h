//
//  OXMAdSDKChoice.h
//  OpenX_iOS_SDK
//
//  Created by Jon Flanders on 7/16/14.
//
//

#import <Foundation/Foundation.h>

@interface OXMAdSDKChoice : NSObject
@property (nonatomic,strong) NSDictionary* adSDKChoiceParameters;
@property (nonatomic,strong) NSString* adSDKChoiceName;
-(instancetype)initFromName:(NSString*)name andParameters:(NSDictionary*)parameters;
+(OXMAdSDKChoice*) adSDKChoiceFromName:(NSString*)name andParameters:(NSDictionary*)parameters;
@property (nonatomic,strong) NSString* trackingURL;
@property (nonatomic,strong) NSString* state;
@end
