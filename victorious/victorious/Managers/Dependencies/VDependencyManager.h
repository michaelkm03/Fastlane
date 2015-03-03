//
//  VDependencyManager.h
//  victorious
//
//  Created by Josh Hinman on 10/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// multi-purpose keys
extern NSString * const VDependencyManagerTitleKey;
extern NSString * const VDependencyManagerBackgroundKey;
extern NSString * const VDependencyManagerImageURLKey;

// Keys for colors
extern NSString * const VDependencyManagerBackgroundColorKey;
extern NSString * const VDependencyManagerSecondaryBackgroundColorKey;
extern NSString * const VDependencyManagerMainTextColorKey;
extern NSString * const VDependencyManagerContentTextColorKey;
extern NSString * const VDependencyManagerAccentColorKey;
extern NSString * const VDependencyManagerSecondaryAccentColorKey;
extern NSString * const VDependencyManagerLinkColorKey;
extern NSString * const VDependencyManagerSecondaryLinkColorKey;

// Keys for fonts
extern NSString * const VDependencyManagerHeaderFontKey;
extern NSString * const VDependencyManagerHeading1FontKey;
extern NSString * const VDependencyManagerHeading2FontKey;
extern NSString * const VDependencyManagerHeading3FontKey;
extern NSString * const VDependencyManagerHeading4FontKey;
extern NSString * const VDependencyManagerParagraphFontKey;
extern NSString * const VDependencyManagerLabel1FontKey;
extern NSString * const VDependencyManagerLabel2FontKey;
extern NSString * const VDependencyManagerLabel3FontKey;
extern NSString * const VDependencyManagerLabel4FontKey;
extern NSString * const VDependencyManagerButton1FontKey;
extern NSString * const VDependencyManagerButton2FontKey;

// Keys for experiments (these should be retrieved with -numberForKey:, as a bool wrapped in an NSNumber)
extern NSString * const VDependencyManagerHistogramEnabledKey;
extern NSString * const VDependencyManagerProfileImageRequiredKey;

// Keys for view controllers
extern NSString * const VDependencyManagerScaffoldViewControllerKey; ///< The "scaffold" is the view controller that sits at the root of the view controller heirarchy
extern NSString * const VDependencyManagerInitialViewControllerKey; ///< The view controller to be displayed on launch

// Keys for Workspace
extern NSString * const VDependencyManagerWorkspaceFlowKey;
extern NSString * const VDependencyManagerImageWorkspaceKey;
extern NSString * const VDependencyManagerVideoWorkspaceKey;

/**
 Provides loose coupling between components.
 Acts as both repository of shared objects
 and a factory of new objects.
 */
@interface VDependencyManager : NSObject

/**
 Creates the root of the dependency manager.
 
 @param parentManager The next dependency manager up in the hierarchy
 @param configuration A dictionary that graphs the dependencies between objects returned by this manager
 @param classesByTemplatename A [string:string] dictionary where the keys are names
                              that may appear in template files, and the values are
                              class names. If nil, it will be read from TemplateClasses.plist.
 */
- (instancetype)initWithParentManager:(VDependencyManager *)parentManager
                        configuration:(NSDictionary *)configuration
    dictionaryOfClassesByTemplateName:(NSDictionary *)classesByTemplateName NS_DESIGNATED_INITIALIZER;

/**
 Returns the color with the specified key
 */
- (UIColor *)colorForKey:(NSString *)key;

/**
 Returns the font with the specified key
 */
- (UIFont *)fontForKey:(NSString *)key;

/**
 Returns the string with the specified key
 */
- (NSString *)stringForKey:(NSString *)key;

/**
 Returns the NSNumber with the specified key
 */
- (NSNumber *)numberForKey:(NSString *)key;

/**
 Returns the UIImage with the specified key
 */
- (UIImage *)imageForKey:(NSString *)key;

/**
 Returns a new instance of a view controller with the specified key
 */
- (UIViewController *)viewControllerForKey:(NSString *)key;

/**
 Returns a singleton instance of a view controller with the specified key
 */
- (UIViewController *)singletonViewControllerForKey:(NSString *)key;

/**
 Returns the NSArray with the specified key. If the array
 elements contain configuration dictionaries for dependant
 objects, those configuration dictionaries can be passed
 into -objectFromDictionary to instantiate a new object.
 */
- (NSArray *)arrayForKey:(NSString *)key;

/**
 Returns an NSArray with the specified key. The array
 will be filtered for objects conforming to the 
 specified type.
 */
- (NSArray *)arrayOfValuesOfType:(Class)expectedType forKey:(NSString *)key;

/**
 Returns an NSArray with the specified key. The array
 will be filtered for objects conforming to the
 specified type. If any of the array elements have
 been previously returned, the previous value will
 be returned again.
 */
- (NSArray *)arrayOfSingletonValuesOfType:(Class)expectedType forKey:(NSString *)key;

/**
 Returns the value stored for the specified key in the configuration
 dictionary of this instance, if present, or the closest ancestor.
 
 @param expectedType if the value found at key is not this kind
 of class, we return nil.
 */
- (id)templateValueOfType:(Class)expectedType forKey:(NSString *)key;

/**
 Returns the value stored for the specified key in the configuration
 dictionary of this instance, if present, or the closest ancestor.
 
 @param expectedType if the value found at key is not this kind
 of class, we return nil.
 @param dependencies If the returned object conforms to VHasManagedDependencies,
 a new instance of VDependencyManager will be provided to it, and these
 extra dependencies will be added to it.
 */
- (id)templateValueOfType:(Class)expectedType forKey:(NSString *)key withAddedDependencies:(NSDictionary *)dependencies;

/**
 Returns a singleton object stored for the specified key in the configuration
 dictionary of this instance, if present, or the closest ancestor.
 
 @discussion
 Calling this method twice with the same key will return the same
 object both times.
 
 @param expectedType if the value found at key is not this kind
 of class, we return nil.
 */
- (id)singletonObjectOfType:(Class)expectedType forKey:(NSString *)key;

/**
 Returns a new object defined by the given configuration dictionary
 
 @param expectedType The type of object you expect to get back
 @param configurationDictionary A dictionary of configuration attributes that describes the object
 @return An object described by the configurationDictionary,
 or nil if no such key exists or is of the wrong type.
 */
- (id)objectOfType:(Class)expectedType fromDictionary:(NSDictionary *)configurationDictionary;

/**
 Returns a singleton object defined by the given configuration dictionary
 
 @discussion
 Calling this method twice with the same dictionary will return the same
 object both times.
 
 @param expectedType The type of object you expect to get back
 @param configurationDictionary A dictionary of configuration attributes that describes the object
 */
- (id)singletonObjectOfType:(Class)expectedType fromDictionary:(NSDictionary *)configurationDictionary;

/**
 Creates and returns a new dependency manager with the given configuration dictionary. The
 new dependency manager will have the receiver as its parent, and any dependencies
 it can't resolve will be passed up the heirarchy.
 
 @param configuration A dictionary describing the dependencies that will be provided
                      by the new manager.
 */
- (VDependencyManager *)childDependencyManagerWithAddedConfiguration:(NSDictionary *)configuration;

@end
