//
//  VThemeManager.h
//  victoriOS
//
//  Created by Gary Philipp on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern  NSString*   const   kVThemeManagerThemeDidChange;

extern  NSString*   const   kVChannelURLAbout;
extern  NSString*   const   kVChannelURLPrivacy;
extern  NSString*   const   kVChannelURLAcknowledgements;
extern  NSString*   const   kVChannelURLSupport;
extern  NSString*   const   kVChannelName;

extern  NSString*   const   kVAgreementText;
extern  NSString*   const   kVAgreementLinkText;
extern  NSString*   const   kVAgreementLink;

extern  NSString*   const   kVMenuBackgroundImage;
extern  NSString*   const   kVMenuBackgroundImage5;
extern  NSString*   const   kMenuTextFont;
extern  NSString*   const   kMenuTextColor;

//Fonts
extern  NSString*   const   kVStreamLocationFont;
extern  NSString*   const   kVStreamUsernameFont;
extern  NSString*   const   kVStreamDateFont;
extern  NSString*   const   kVStreamDescriptionFont;

extern  NSString*   const   kVCommentUsernameFont;

extern  NSString*   const   kVCreatePostFont;
extern  NSString*   const   kVCreatePostButtonFont;
//Colors
extern  NSString*   const   kVStreamSearchBarColor;

extern  NSString*   const   kVCreatePollQuestionBorderColor;
extern  NSString*   const   kVCreatePollQuestionColor;
extern  NSString*   const   kVCreatePollQuestionLeftBGColor;
extern  NSString*   const   kVCreatePollQuestionRightBGColor;
extern  NSString*   const   kVCreatePollQuestionLeftColor;
extern  NSString*   const   kVCreatePollQuestionRightColor;

extern  NSString*   const   KVRemoveMediaButtonColor;
extern  NSString*   const   kVCreatePostMediaLabelColor;
extern  NSString*   const   kVCreatePostMediaButtonColor;
extern  NSString*   const   kVCreatePostBackgroundColor;
extern  NSString*   const   kVCreatePostMediaButtonBGColor;

extern  NSString*   const   kVCreatePostTextColor;

extern  NSString*   const   kVCreatePostInputBorderColor;
extern  NSString*   const   kVCreatePostButtonTextColor;
extern  NSString*   const   kVCreatePostButtonBGColor;
extern  NSString*   const   kVCreatePostCountInvalidColor;
extern  NSString*   const   kVCreatePostCountColor;
@interface VThemeManager : NSObject

+ (VThemeManager *)sharedThemeManager;

- (void)setTheme:(NSDictionary *)dictionary;

- (void)applyStyling;
- (void)removeStyling;

- (id)themedValueForKeyPath:(NSString *)keyPath;

- (NSString *)themedStringForPath:(NSString *)keyPath;
- (UIColor *)themedColorForKeyPath:(NSString *)keyPath;
- (UIColor *)themedTranslucencyColorForKeyPath:(NSString *)keyPath;
- (NSURL *)themedURLForKeyPath:(NSString *)keyPath;
- (NSURL *)themedImageURLForKeyPath:(NSString *)keyPath;
- (UIImage *)themedImageForKeyPath:(NSString *)keyPath;
- (UIFont *)themedFontForKeyPath:(NSString *)keyPath;

@end
