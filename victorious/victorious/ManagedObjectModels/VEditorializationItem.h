//
//  VEditorializationItem.h
//  
//
//  Created by Sharif Ahmed on 7/13/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStreamItem;

@interface VEditorializationItem : NSManagedObject

@property (nonatomic, retain) NSString *streamItemId;
@property (nonatomic, retain) NSString *headline;
@property (nonatomic, retain) NSString *streamId;
@property (nonatomic, retain) VStreamItem *streamItem;

@end
