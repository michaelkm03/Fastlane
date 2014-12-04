//
//  TremorVideoAd.h
//  TremorVideoAd
//

#import <UIKit/UIKit.h>

typedef enum {
	ORIENTATION_ANY = 0,
	ORIENTATION_LANDSCAPE,
	ORIENTATION_PORTRAIT
}ePreferredOrientation;

typedef enum  {
	GENDER_UNKNOWN = 0,
	GENDER_MALE,
	GENDER_FEMALE,
	GENDER_LAST
}eUserGender;

typedef enum  {
    EDUCATION_UNKNOWN = 0,
    EDUCATION_LESS_THAN_HIGHSCHOOL,
    EDUCATION_SOME_HIGHSCHOOL,
    EDUCATION_HIGHSCHOOL,
    EDUCATION_SOME_COLLEGE,
    EDUCATION_COLLEGE_BACHELOR,
    EDUCATION_COLLEGE_MASTERS,
    EDUCATION_COLLEGE_PROFESSIONAL,
    EDUCATION_COLLEGE_PHD,
    EDUCATION_LAST
}eUserEducation;

typedef enum  {
    RACE_UNKNOWN = 0,
    RACE_ASIAN,
    RACE_WHITE,
    RACE_BLACK,
    RACE_HISPANIC,
    RACE_AMERICAN_INDIAN,
    RACE_ALASKA_NATIVE,
    RACE_NATIVE_HAWAIIAN,
    RACE_PACIFIC_ISLANDER,
    RACE_OTHER
}eUserRace;

typedef enum  {
    INCOME_UNKNOWN = 0,
    INCOME_LESS_THAN_25K,
    INCOME_25K_50K,
    INCOME_50K_75K,
    INCOME_75K_100K,
    INCOME_100K_150K,
    INCOME_150K_200K,
    INCOME_200K_250K,
    INCOME_ABOVE_250K
}eIncome;


@interface TremorVideoSettings : NSObject {
    
}

@property (nonatomic) ePreferredOrientation preferredOrientation;
@property (nonatomic, retain) NSArray *category;
@property (nonatomic) eUserGender userGender;
@property (nonatomic) eUserEducation userEducation;
@property (nonatomic) eUserRace userRace;
@property (nonatomic) eIncome userIncomeRange;
@property (nonatomic) NSUInteger userAge;
@property (nonatomic, retain) NSString *userZip;
@property (nonatomic) double userLatitude;
@property (nonatomic) double userLongitude;
@property (nonatomic, retain) NSString *userLanguage;
@property (nonatomic, retain) NSString *userCountry;
@property (nonatomic, retain) NSArray *userInterests; 
@property (nonatomic, retain) NSDictionary *misc; 
@property (nonatomic) NSUInteger maxAdTimeSeconds;
@property (nonatomic, retain) NSString *policyID;
@property (nonatomic, retain) NSArray *adBlocks; 
@property (nonatomic, retain) NSString *contentTitle;
@property (nonatomic, retain) NSString *contentDescription;
@property (nonatomic, retain) NSString *contentID;

@end


@protocol TremorVideoAdDelegate <NSObject>
@optional
- (void)didAdComplete;
- (void)didAdComplete:(BOOL)adCompleted;
@end


@interface TremorVideoAd : NSObject {

}

+ (void)initWithAppID:(NSString *)appID;
+ (void)initWithAppIDList:(NSArray *)appIDs;
+ (void)start;
+ (void)stop;
+ (void)destroy;
+ (BOOL)showAd:(UIViewController *)parentViewController;
+ (BOOL)showAdWithAppID:(NSString *)appID onViewController:(UIViewController *)parentViewController;
+ (BOOL)showAd:(UIViewController *)parentViewController withFrame:(CGRect)frame;
+ (BOOL)showAdWithAppID:(NSString *)appID onViewController:(UIViewController *)parentViewController withFrame:(CGRect)frame;
+ (BOOL)showVASTAd:(UIViewController *)parentViewController vastURL:(NSString *)url;
+ (BOOL)showVASTAd:(UIViewController *)parentViewController vastURL:(NSString *)url skipDelay:(int)skipDelay;
+ (BOOL)showVASTAd:(UIViewController *)parentViewController vastURL:(NSString *)url waterMark:(BOOL)waterMark;
+ (BOOL)showVASTAd:(UIViewController *)parentViewController vastURL:(NSString *)url skipDelay:(int)skipDelay waterMark:(BOOL)waterMark;
+ (UIView *)adView;
+ (void)setFrame:(CGRect)frame;
+ (NSString *)getVersion;
+ (TremorVideoSettings *)getSettings;
+ (void)setDelegate:(id<TremorVideoAdDelegate>)delegate;

+ (void)handleAnalyticsEvent:(NSString *)event;
+ (void)handleAnalyticsEvent:(NSString *)event parameters:(NSDictionary *)parameters;
+ (void)handleAnalyticsStateChange:(NSString *)newState;
@end
