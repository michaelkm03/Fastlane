//
//  UserModel.swift
//  victorious
//
//  Created by Tian Lan on 5/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Conformers are models that store information about a user in the app
/// Consumers can directly use this type without caring what the concrete type is, persistent or not.
protocol UserModel {
    var id: Int { get }
    var email: String? { get }
    var name: String? { get }
    var completedProfile: Bool? { get }
    var location: String? { get }
    var tagline: String? { get }
    var fanLoyalty: FanLoyalty? { get }
    var isBlockedByCurrentUser: Bool? { get }
    var accessLevel: User.AccessLevel? { get }
    var isFollowedByCurrentUser: Bool? { get }
    var likesGiven: Int? { get }
    var likesReceived: Int? { get }
    var previewImageModels: [ImageAssetModel] { get }
    var avatarBadgeType: AvatarBadgeType { get }
    var vipStatus: VIPStatus? { get }
}

extension User: UserModel {
    var previewImageModels: [ImageAssetModel] {
        return previewImageAssets.map { $0 }
    }
}
