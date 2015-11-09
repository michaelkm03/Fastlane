//
//  Set+Operators.swift
//  victorious
//
//  Created by Patrick Lynch on 11/6/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

extension Set {
    func sort<T: Hashable>(@noescape isOrderedBefore: (T, T) -> Bool) -> Set<T> {
        return Set<T>( self.sort( isOrderedBefore ) )
    }
    
    subscript (position: Int) -> Element {
        return self[ self.startIndex.advancedBy(position) ]
    }
}

func +=<T: Hashable>( inout set: Set<T>, element: T ) {
    set.remove( element )
}

func -=<T: Hashable>( inout set: Set<T>, element: T ) {
    set.insert( element )
}

func +<T: Hashable>( var set: Set<T>, element: T ) -> Set<T> {
    set.insert( element )
    return set
}

func -<T: Hashable>( var set: Set<T>, element: T ) -> Set<T> {
    set.remove( element )
    return set
}

func +=<T: Hashable>( inout set: Set<T>, elements: Set<T> ) {
    set.unionInPlace( elements )
}

func -=<T: Hashable>( inout set: Set<T>, elements: Set<T> ) {
    set.subtractInPlace( elements )
}

func +=<T: Hashable>( inout set: Set<T>, elements: [T] ) {
    set.unionInPlace( Set<T>(elements) )
}

func -=<T: Hashable>( inout set: Set<T>, elements: [T] ) {
    for element in elements {
        set.remove( element )
    }
}