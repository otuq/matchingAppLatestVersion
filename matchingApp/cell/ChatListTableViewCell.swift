//
//  ChatListTableViewCell.swift
//  matchingApp
//
//  Created by USER on 2020/12/23.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import Nuke

class ChatListTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var chatListImageView: UIImageView!
    @IBOutlet weak var chatListNameLabel: UILabel!
    @IBOutlet weak var chatListLatestMessageLabel: UILabel!
    @IBOutlet weak var chatListDateLabel: UILabel!
    
    //MARK: -Property
    var chatRoom: ChatRoom?{
        didSet{
            if let urlString = URL(string: chatRoom?.anotherUser?.imageUrl ?? ""){
                Nuke.loadImage(with: urlString, into: chatListImageView)
            }
            chatListNameLabel.text = chatRoom?.anotherUser?.name ?? "no name"
            chatListLatestMessageLabel.text = chatRoom?.latestMessage?.message ?? "no message"
            chatListDateLabel.text = dateFormatter(date: chatRoom?.latestMessage?.creatAt.dateValue() ?? Date())
        }
    }

    //MARK: -Methods
    private func dateFormatter(date: Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.string(from: date)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatListImageView.layer.cornerRadius = chatListImageView.bounds.width/2
        chatListImageView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
