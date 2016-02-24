//
//  VStreamCollectionViewController+TrendingShelfResponder.swift
//  victorious
//
//  Created by Tian Lan on 9/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

extension VStreamCollectionViewController: VShelfStreamItemSelectionResponder, VTrendingUserShelfResponder, VTrendingHashtagShelfResponder {
    func navigateTo(streamItem: VStreamItem?, fromShelf: Shelf) {
        navigateToStream(fromShelf, atStreamItem: streamItem)
    }
    
    func trendingUserShelfSelected(user: VUser, fromShelf: UserShelf) {
        sequenceActionController.showProfile(user)
    }
    
    func trendingHashtagShelfSelected(hashtag: String, fromShelf: HashtagShelf) {
        showHashtagStreamWithHashtag(hashtag)
    }
}
