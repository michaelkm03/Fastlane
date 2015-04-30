//
//  VTemplateDecorator.h
//  victorious
//
//  Created by Patrick Lynch on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A decorator object for a template dictionary that allows the easy modification of that
 template according to many of the development and production needs of this app.
 */
@interface VTemplateDecorator : NSObject

/**
 Designated initializer that takes in the required template dictionary to which modifications
 will be made.  Use the `decoratedTemplate` property to get access to an NSDictionary instance
 that contains modifications made during the lifetime of this object.
 */
- (instancetype)initWithTemplateDictionary:(NSDictionary *)templateDictionary NS_DESIGNATED_INITIALIZER;

/**
 Simple utility method that loads a JSON file from the app bundle accoding to the
 provided filename and parses it into a dictionary.
 
 @param filename Name of the file (without extension) to load from bundle
 @throws Assertion when no such file is present in the bundle.
 */
+ (NSDictionary *)dictionaryFromJSONFile:(NSString *)filename;

/**
 Add the provided component to the top level of the template, thereby concatenating it.
 Any keys used at the top level of the component will overwite those already
 in present on the templste.
 
 @param filename The name of the file (without its json extension) in the bundle that contains
 a component to be parsed in a dictionary and added to the template.
 @return Boolean that indicates whether the component was successfully concatenated.
 */
- (BOOL)concatenateTemplateWithFilename:(NSString *)filename;

/**
 Loads a JSON file from the app bundle with the specified filename, parses it into a dictionary
 and then adds that dictionary as a template value with the specified keypath using the
 `setTemplateValue:forKeyPath:` method of this class.
 
 @see `setTemplateValue:forKeyPath:`
 */
- (BOOL)setComponentWithFilename:(NSString *)filename forKeyPath:(NSString *)keyPath;

/**
 Adds a new component to the template by adding or overwriting at the speciifed key path.
 
 @param keyPath A slash-separated path that indicates where in the hierarchy of dictionary keys
 and array indexes to place the new component.  For example, the key path "key1/key2/4/key3"
 will add the component for "key3" of a dictionary at index 5 of an array at "key2" of a
 dictionary at "key1".  If the last path component is an index, that index in the array will
 be overwritten if present, or the component will be added to the end of the array if not present.
 If any objects are not dictionaries or arrays as implied by the keypath, the operation will fail
 and return NO.
 @param filename The name of the file (without its json extension) in the bundle that contains
 a component to be parsed in a dictionary and added to the template.
 @return Boolean that indicates whether the keypath provided was valid and the method was
 able to add the component.
 */

- (BOOL)setTemplateValue:(id)templateValue forKeyPath:(NSString *)keyPath;

/**
 Returns the current value with any previous decorations for the specified keypath.
 
 @param keyPath A slash-separated path that indicates where in the hierarchy of dictionary keys
 and array indexes to place the new component.
 @return Object at the specified key path or nil if not found.
 */
- (id)templateValueForKeyPath:(NSString *)keyPath;

/**
 Recursively finds all keys that match the specified key and replaces the
 existing value with the specified value.
 
 @param key The key for which to search and replace all corresponding values.
 @param templateValue The new value to set, generam should be an NSNumber, NSString,
 NSDictinoary or NSArray, and must not be nil.
 */
- (void)setValue:(id)templateValue forAllOccurencesOfKey:(NSString *)key;

/**
 Searches recursively for all instances of the specified key and returns the complete key paths
 for each one.  These key paths are in the format that this class accepts in the
 `setTemplateValue:forKeyPath:` and `setComponentWithFilename:forKeyPath:` methods.  The idea
 is that during development you might use `keyPathsForKey:` to quickly search for the key paths
 of the template values that you are interested in modifying or replacing.  Otherwise, you'd have
 to manually search through the template and construct the key paths yourself, which is time-consuming.
 
 @param key The last path component of one or more complete key path that will be returned, if found.
 @return An array of strings representing key paths.  Returns an empty array if none are found.
 */
- (NSArray *)keyPathsForKey:(NSString *)key;

/**
 Returns output as an NSDictionary instance which contains all modifications
 that have yet been made to the template using any of the methods available on this class.
 */
@property (nonatomic, readonly) NSDictionary *decoratedTemplate;

@end
