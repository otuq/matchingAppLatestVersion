//
//  ChatMessageViewController.swift
//  matchingApp
//
//  Created by USER on 2022/2/16.
//  Copyright © 2022 otuq. All rights reserved.
//

import InputBarAccessoryView
import MessageKit
import Nuke
import UIKit

// MARK: MessagekitSender
struct Sender: SenderType {
    var senderId: String
    var displayName: String
}
protocol ChatMessageOutput: AnyObject {
    var chatRoomPresent: ChatRoom? { get }
    func messageListAppend(message: MockMessage)
    func messageListRemove()
}
class ChatMessageViewController: MessagesViewController {
    // MARK: Properties
    private lazy var messageList = [MockMessage]()
    private var presenter: ChatMessagePresenter!
    var chatRoom: ChatRoom? // ChatListVCのセルがdidselectされたらデータが渡ってくる。

    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        presenter.fetchChatRoom()
        messageKitSetting()
        // メッセージを開いた時最新メッセージまでスクロール
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem()
        }
        navigationItem.title = "チャットルーム"
    }
    private func initialize() {
        presenter = ChatMessagePresenter(with: self)
    }
    private func messageKitSetting() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
// MARK: - Presenter
extension ChatMessageViewController: ChatMessageOutput {
    var chatRoomPresent: ChatRoom? { chatRoom }
    func messageListAppend(message: MockMessage) {
        self.messageList.append(message)
        self.messagesCollectionView.reloadData()
        // 最新メッセージを取得するとスクロールする
        self.messagesCollectionView.scrollToLastItem()
    }
    func messageListRemove() {
        messageList.removeAll()
        messagesCollectionView.reloadData()
    }
}
// MARK: - InputBarAccessoryViewDelegate
extension ChatMessageViewController: InputBarAccessoryViewDelegate {
    // 送信ボタンを押した時の処理
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        presenter.sendMessageFirestore(text: text)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
}
// MARK: - MessagesDataSource
extension ChatMessageViewController: MessagesDataSource {
    // 自身の情報を設定する
    func currentSender() -> SenderType {
        return Sender(senderId: presenter.uid, displayName: chatRoom?.currentUser?.name ?? "no name")
    }
    // indexpathでメッセージの中身を呼び出す
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messageList.sort { m1, m2 -> Bool in
            let sort1 = m1.sentDate
            let sort2 = m2.sentDate
            return sort1 < sort2
        }
        // collectionViewとかの時だとsectionじゃなくrow使うが、messageKitだとsectionみたい
        return messageList[indexPath.section]
    }
    // 表示するメッセージの数
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    // messageの上のLabel
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor.dynamicColor(light: .darkGray, dark: .white)])
    }
    // messageの下のLabel
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dated = messageList[indexPath.section].sentDate
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let date = dateFormatter.string(from: dated)
        return NSAttributedString(string: date, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor.dynamicColor(light: .darkGray, dark: .white)])
    }
}
// MARK: - MessageCellDelegate
extension ChatMessageViewController: MessageCellDelegate {
    // メッセージをタップした時の処理
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("tapMessage")
    }
}
// MARK: - MessagesDisplayDelegate
extension ChatMessageViewController: MessagesDisplayDelegate {
    // メッサージの色を変更
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white: .white
    }
    // メッセージの背景色を変更
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .systemBlue: .systemPink
    }
    // メッセージのしっぽ
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    // アイコンのセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if presenter.uid == message.sender.senderId {
            guard let url = URL(string: self.chatRoom?.currentUser?.imageUrl ?? "") else { return }
            Nuke.loadImage(with: url, into: avatarView)
        } else {
            guard let url = URL(string: self.chatRoom?.anotherUser?.imageUrl ?? "") else { return }
            Nuke.loadImage(with: url, into: avatarView)
        }
    }
}
// MARK: - MessagesLayoutDelegate
extension ChatMessageViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}
