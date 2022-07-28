//
//  ChatListViewController.swift
//  matchingApp
//
//  Created by USER on 2022/2/23.
//  Copyright © 2022 otuq. All rights reserved.
//

import UIKit

protocol ChatListOutput: AnyObject {
    func chatRoomRemove()
    func chatRoomAppend(chatRoom: ChatRoom)
}
class ChatListViewController: UIViewController {
    // MARK: Properties
    private let cellId = "cellId"
    private var currentUser: User?
    private var presenter: ChatListPresenter!
    private var chatRooms = [ChatRoom]()

    // MARK: - Outlets
    @IBOutlet var chatListTableView: UITableView!

    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        settingView()
        notification()
        presenter.fetchUserInfo { user in
            self.currentUser = user
        }
        presenter.fetchChatRoom()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 遷移先から戻ってきた時cellの選択を解除する
        if let indexPath = chatListTableView.indexPathForSelectedRow {
            UIView.animate(withDuration: 1) {
                self.chatListTableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    private func initialize() {
        presenter = ChatListPresenter(with: self)
    }
    private func settingView() {
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        chatListTableView.register(UINib(nibName: "ChatListTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        navigationItem.title = "チャットリスト"
    }
    private func notification() {
        // ChatMessageVCから通知
        NotificationCenter.default.addObserver(self, selector: #selector(latestMessageUpdate), name: .latestMessageUpdate, object: nil)
        // StartUpVCから通知
        NotificationCenter.default.addObserver(self, selector: #selector(signUpLoad), name: .signUpLoad, object: nil)
        // ProfileVCから通知
        NotificationCenter.default.addObserver(self, selector: #selector(profileUpdate), name: .profileUpdate, object: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
// MARK: - Presenter
extension ChatListViewController: ChatListOutput {
    func chatRoomRemove() {
        chatRooms.removeAll()
        chatListTableView.reloadData()
    }
    func chatRoomAppend(chatRoom: ChatRoom) {
        self.chatRooms.append(chatRoom)
        self.chatListTableView.reloadData()
    }
}
// MARK: - Notifications
extension ChatListViewController {
    @objc private func profileUpdate() {
        presenter.fetchUserInfo { user in
            self.currentUser = user
            self.chatListTableView.reloadData()
        }
    }
    @objc private func signUpLoad() {
        presenter.fetchChatRoom()
    }
    @objc private func latestMessageUpdate() {
        presenter.fetchChatRoom()
    }
}
// MARK: - UITableViewDelegate, UITableViewDataSource
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatRooms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId)as! ChatListTableViewCell
        self.chatRooms.sort { s1, s2 -> Bool in
            let sort1 = s1.creatAt.dateValue()
            let sort2 = s2.creatAt.dateValue()
            return sort1 > sort2
        }
        cell.chatRoom = chatRooms[indexPath.row]
        cell.chatRoom?.currentUser = self.currentUser
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ChatMessage", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ChatMessageViewController")as! ChatMessageViewController
        viewController.chatRoom = chatRooms[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            alertAppear {
                guard let chatRoomId = self.chatRooms[indexPath.row].documentId else { return }
                self.presenter.deleteChatRoom(chatRoomId: chatRoomId)
                self.chatRooms.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    private func alertAppear(complition: @escaping () -> Void) {
        let message = "本当にチャットルームを削除しますか？", titleA = "いいえ", titleB = "削除する"
        let alertController = UIAlertController(title: .none, message: message, preferredStyle: .alert)
        let actionA = UIAlertAction(title: titleA, style: .cancel)
        let actionB = UIAlertAction(title: titleB, style: .default) { _ in
            complition()
        }
        [actionA, actionB].forEach { action in
            alertController.addAction(action)
        }
        present(alertController, animated: true)
    }
}
