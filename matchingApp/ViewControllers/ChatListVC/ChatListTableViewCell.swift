//
//  ChatListTableViewCell.swift
//  matchingApp
//
//  Created by USER on 2022/2/23.
//  Copyright © 2022 otuq. All rights reserved.
//

import Nuke
import UIKit

class ChatListTableViewCell: UITableViewCell {
    // MARK: - Property
    var chatRoom: ChatRoom? {
        didSet {
            if let urlString = URL(string: chatRoom?.anotherUser?.imageUrl ?? "") {
                Nuke.loadImage(with: urlString, into: chatListImageView)
            }
            chatListNameLabel.text = chatRoom?.anotherUser?.name ?? "no name"
            chatListLatestMessageLabel.text = chatRoom?.latestMessage?.message ?? "no message"
            chatListDateLabel.text = dateFormatter(date: chatRoom?.latestMessage?.creatAt.dateValue() ?? Date())
        }
    }
    // MARK: Outlets
    @IBOutlet var chatListImageView: UIImageView!
    @IBOutlet var chatListNameLabel: UILabel!
    @IBOutlet var chatListLatestMessageLabel: UILabel!
    @IBOutlet var chatListDateLabel: UILabel!

    // MARK: - Methods
    private func dateFormatter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.string(from: date)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        chatListImageView.layer.cornerRadius = chatListImageView.bounds.width / 2
        chatListImageView.contentMode = .scaleAspectFill
    }
}
