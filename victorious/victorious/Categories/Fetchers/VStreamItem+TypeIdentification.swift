//
//  VStreamItem+TypeIdentification.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

//Describes an objc-friendly enum that can identify an enum from a string
protocol Enumerable {
    
    //Return a default value to be used when no items match those from the enum value map.
    static func defaultValue() -> Self
    
    //Return a dictionary of string-keyed enum values.
    static func enumValueMap() -> [ String : Self ]
    
    //2.0 Improvement: Move generic implementation into protocol extension.
    static func normalizedType(string : String?) -> Self

}

//MARK: Type enum declaration
extension VStreamItem {
    
    @objc
    //Describes the base type of this stream item. Ex: Stream, Sequence, Marquee.
    enum VItemType: Int, Enumerable {
        case Sequence, Stream, Marquee, User, Hashtag, Feed, Unknown
        
        static let valueMap = ["sequence" : Sequence, "stream" : Stream, "marquee" : Marquee, "user" : User, "hashtag" : Hashtag, "feed" : Feed]
        
        static func defaultValue() -> VItemType {
            return .Unknown
        }
        
        static func enumValueMap() -> [String : VItemType] {
            return valueMap
        }
        
        //2.0 Improvement: Put this in protocol extension of Enumerable
        static func normalizedType(string : String?) -> VItemType {
            return VStreamItem.enumValue(VItemType.enumValueMap(), matchValue: string)
        }
    }

    @objc
    //Describes the sub type of this stream item. Ex: Image, Video, Poll.
    enum VItemSubType: Int, Enumerable {
        case Image, Video, Poll, Text, Content, Stream, Unknown
        
        static let valueMap = ["image" : Image, "video" : Video, "poll" : Poll, "text" : Text, "content" : Content, "stream" : Stream]
        
        static func defaultValue() -> VItemSubType {
            return .Unknown
        }
        
        static func enumValueMap() -> [String : VItemSubType] {
            return valueMap
        }
        
        //2.0 Improvement: Put this in protocol extension of Enumerable
        static func normalizedType(string : String?) -> VItemSubType {
            return VStreamItem.enumValue(VItemSubType.enumValueMap(), matchValue: string)
        }
    }
    
    //2.0 Improvement: Put this in protocol extension of Enumerable
    static func enumValue<T : Enumerable>(enumMap : [String : T], matchValue : String?) -> T {
        if let string = matchValue {
            if let foundValue = enumMap[string] {
                return foundValue
            }
        }
        return T.defaultValue()
    }
    
}

//MARK: Conversion interface
extension VStreamItem {
    
    @objc
    //The item type of this stream item
    func normalizedItemType() -> VItemType {
        return VStreamItem.normalizedItemType(self.itemType)
    }
    
    @objc
    //The item type for the provided string
    class func normalizedItemType(string : String?) -> VItemType {
        return VItemType.normalizedType(string)
    }
    
    @objc
    //The item sub type of this stream item
    func normalizedItemSubType() -> VItemSubType {
        return VStreamItem.normalizedItemSubType(self.itemSubType)
    }
    
    @objc
    //The item sub type for the provided string
    class func normalizedItemSubType(string : String?) -> VItemSubType {
        return VItemSubType.normalizedType(string)
    }
    
}
