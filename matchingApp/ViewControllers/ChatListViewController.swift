//
//  ChatListViewController.swift
//  matchingApp
//
//  Created by USER on 2020/12/23.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import Firebase

class ChatListViewController: UIViewController {

    let cellId = "cellId"
    var chatRooms = [ChatRoom]()
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingView()
        fetchChatRoom()
    }
    private func settingView(){
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
    }
    private func fetchChatRoom(){
        
        Firestore.firestore().collection("chatRoom").addSnapshotListener { (snapshot, error) in
            if let err = error{
                print("chatRoomの情報の取得に失敗しました。",err)
                return
            }
            snapshot?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type{
                case .added:
                    self.addDocumentChange(documentChange: documentChange)
                case .modified,.removed:
                    print("nothing to do")
                }
            })
        }
    }
    private func addDocumentChange(documentChange: DocumentChange){
        let data = documentChange.document.data()
        let chatRoom = ChatRoom.init(dic: data)
        chatRoom.documentId = documentChange.document.documentID
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if !chatRoom.members.contains(uid){ return }
        chatRoom.members.forEach { (anotherUid) in
            if uid != anotherUid{
                Firestore.firestore().collection("user").document(anotherUid).getDocument { (snapshot, error) in
                    if let err = error {
                        print("パートナーUserの情報の取得に失敗しました。",err)
                    }
                    guard let data = snapshot?.data() else { return }
                    let anotherUser = User.init(dic: data)
                    anotherUser.anotherUid = snapshot?.documentID
                    chatRoom.anotherUser = anotherUser
                    
                }
            }
        }
    }
    
}
extension ChatListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatRooms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId)as! ChatListTableViewCell
        cell.chatRoom = chatRooms[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "ChatMessage", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ChatMessageViewController")as! ChatMessageViewController
        
        self.present(viewController, animated: true, completion: nil)
    }
    
}
