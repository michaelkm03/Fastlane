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
extern NSString * const VDependencyManagerCellBackgroundKey;

// Keys for colors
extern NSString * const VDependencyManagerBackgroundColorKey;
extern NSString * const VDependencyManagerMainTextColorKey;
extern NSString * const VDependencyManagerContentTextColorKey;
extern NSString * const VDependencyManagerSecondaryTextColorKey;
extern NSString * const VDependencyManagerPlaceholderTextColorKey;
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

// Keys for identification
extern NSString * const VDependencyManagerIDKey;

// Keys for experiments (these should be retrieved with -numberForKey:, as a bool wrapped in an NSNumber)
extern NSString * const VDependencyManagerProfileImageRequiredKey;
extern NSString * const VDependencyManagerLikeButtonEnabledKey;
extern NSString * const VDependencyManagerExperimentKeyIDs;
extern NSString * const VDependencyManagerAutoplaySettingsEnabled;

// Keys for view controllers
extern NSString * const VDependencyManagerScaffoldViewControllerKey; ///< The "scaffold" is the view controller that sits at the root of the view controller heirarchy
extern NSString * const VDependencyManagerInitialViewControllerKey; ///< The view controller to be displayed on launch

// Keys for Workspace
extern NSString * const VDependencyManagerWorkspaceFlowKey;
extern NSString * const VDependencyManagerTextWorkspaceFlowKey;
extern NSString * const VDependencyManagerImageWorkspaceKey;
extern NSString * const VDependencyManagerVideoWorkspaceKey;
extern NSString * const VDependencyManagerEditTextWorkspaceKey;
extern NSString * const VDependencyManagerNativeWorkspaceKey;

@protocol Scaffold;

/**
 Provides loose coupling between components.
 Acts as both repository of shared objects
 and a factory of new objects.
 */
@interface VDependencyManager : NSObject

/**
 Provides a copy of the "templateClasses.plist" data used internally for instantiating
 tempalte components.
 */
@property (nonatomic, copy, readonly) NSDictionary *defaultDictionaryOfClassesByTemplateName;

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

- (instancetype)init NS_UNAVAILABLE;

/**
 Checks for an entry in internal configuration by provided key.
 Does not look in parent dependency managers, only checks at the local level.
 */
- (BOOL)containsKey:(NSString *)key;

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
 Returns a reference to the singleton instance of the current template's scaffolding
 */
- (UIViewController<Scaffold> *)scaffoldViewController;

/**
 Returns the NSArray with the specified key. If the array
 elements contain configuration dictionaries for dependant
 objects, those objects will be instantiated and added to
 the array.
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
 Returns an NSArray with the specified key. The array
 will be filtered for objects conforming to the
 specified protocol.
 */
- (NSArray *)arrayOfValuesConformingToProtocol:(Protocol *)protocol forKey:(NSString *)key;

/**
 Returns an NSArray with the specified key. The array
 will be filtered for objects conforming to the
 specified protocol. If any of the array elements have
 been previously returned, the previous value will
 be returned again.
 */
- (NSArray *)arrayOfSingletonValuesConformingToProtocol:(Protocol *)protocol forKey:(NSString *)key;

/**
 Returns an NSArray of UIImage objects specified in a macro format.
 (See "Image Macros" in the template spec for details)
 */
- (NSArray *)arrayOfImagesForKey:(NSString *)key;

/**
 Returns YES if a call to -arrayOfImagesForKey: with a given key is
 likely to sucessfully return an array of images. If such a call
 is likely (or guaranteed) to result in an empty array, this
 method will return NO.
 */
- (BOOL)hasArrayOfImagesForKey:(NSString *)key;

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
 Returns the value stored for the specified key in the configuration
 dictionary of this instance, if present, or the closest ancestor.
 
 @param expectedTypes if the value found at key is not any of these
 classes, we return nil.
 @param dependencies If the returned object conforms to VHasManagedDependencies,
 a new instance of VDependencyManager will be provided to it, and these
 extra dependencies will be added to it.
 */
- (id)templateValueMatchingAnyType:(NSArray<Class> *)expectedTypes forKey:(NSString *)key withAddedDependencies:(NSDictionary *)dependencies;

/**
 Returns the value stored for the specified key in the configuration
 dictionary of this instance, if present, or the closest ancestor.
 
 @param expectedType if the value found at key does not conform 
                     to this protocol, of class, we return nil.
 */
- (id)templateValueConformingToProtocol:(Protocol *)protocol forKey:(NSString *)key;

/**
 Returns the value stored for the specified key in the configuration
 dictionary of this instance, if present, or the closest ancestor.
 
 @param protocol If the value found at key does not conform to this protocol, we return nil.
 @param dependencies If the returned object conforms to VHasManagedDependencies,
                     a new instance of VDependencyManager will be provided to it, and these
                     extra dependencies will be added to it.
 */
- (id)templateValueConformingToProtocol:(Protocol *)protocol forKey:(NSString *)key withAddedDependencies:(NSDictionary *)dependencies;

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
 Performs necessary cleanup before deallocating the receiver. 
 After calling this method, any further method calls to this
 object or its children and grandchildren should be avoided.
 
 @discussion
 VDependencyManager creates several retain cycles as part of
 its design. This method exists to break those cycles when
 a new session starts, or any other case in which you are about
 to deallocate this dependency manager and instantiate a brand
 new one from scratch (i.e., without a parent-child relationship
 to an existing instance of VDependencyManager).
 
 NOTE: This method only has effect if the receiver has no parent 
 dependency manager. This ensures that any random object with a
 reference to a child manager can't mess things up for everyone
 else.
 */
- (void)cleanup;

/**
 Creates and returns a new dependency manager with the given configuration dictionary. The
 new dependency manager will have the receiver as its parent, and any dependencies
 it can't resolve will be passed up the heirarchy.
 
 @param configuration A dictionary describing the dependencies that will be provided
                      by the new manager.
 */
- (VDependencyManager *)childDependencyManagerWithAddedConfiguration:(NSDictionary *)configuration;

/**
 Marshalls a dictionary in the expected format into a UIColor object.
 Returns nil if failed.
 */
+ (UIColor *)colorFromDictionary:(NSDictionary *)colorDictionary;

/**
 Marshalls a UIColor into a dictionary in the expected template format.
 Returns nil if failed.
 */
+ (NSDictionary *)dictionaryFromColor:(UIColor *)color;

@end
