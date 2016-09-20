//
//  File.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class ListMenuChatRoomCollectionViewCell: UICollectionViewCell, ListMenuSectionCell {

    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - ListMenuSectionCell

    var dependencyManager: VDependencyManager?

    func configureCell(with chatRoom: ChatRoom) {
        titleLabel.text = "\(chatRoom.name)"
    }
}
