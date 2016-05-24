//
//  UserModel.swift
//  victorious
//
//  Created by Tian Lan on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol UserModel {
    var id: Int { get }
    var email: String? { get }
    var name: String? { get }
    var completedProfile: Bool? { get }
    var location: String? { get }
    var tagline: String? { get }
    var fanLoyalty: FanLoyalty? { get }
    var isBlockedByMainUser: Bool? { get }
    var accessLevel: User.AccessLevel? { get }
    var isDirectMessagingDisabled: Bool? { get }
    var isFollowedByMainUser: Bool? { get }
    var numberOfFollowers: Int? { get }
    var numberOfFollowing: Int? { get }
    var likesGiven: Int? { get }
    var likesReceived: Int? { get }
    var tokenUpdatedAt: NSDate? { get }
    var previewImageAssets: [ImageAsset]? { get }
    var maxVideoUploadDuration: Int? { get }
    var avatar: Avatar? { get }
    var vipStatus: VIPStatus? { get }
}
