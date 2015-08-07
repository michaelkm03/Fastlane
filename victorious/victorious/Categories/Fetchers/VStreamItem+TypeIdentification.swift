//
//  VStreamItem+TypeIdentification.swift
//  victorious
//
//  Created by Sharif Ahmed on 8/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

protocol Enumerable {
    
    static func defaultValue() -> Self
    static func enumValueMap() -> [ String : Self ]
    
    //2.0 Improvement: Move generic implementation into protocol extension
    static func normalizedType(string : String?) -> Self

}

//MARK: Type enum declaration
extension VStreamItem {
    
    @objc
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
    func normalizedItemType() -> VItemType {
        return VStreamItem.normalizedItemType(self.itemType)
    }
    
    @objc
    class func normalizedItemType(string : String?) -> VItemType {
        return VItemType.normalizedType(string)
    }
    
    @objc
    func normalizedItemSubType() -> VItemSubType {
        return VStreamItem.normalizedItemSubType(self.itemSubType)
    }
    
    @objc
    class func normalizedItemSubType(string : String?) -> VItemSubType {
        return VItemSubType.normalizedType(string)
    }
    
}
