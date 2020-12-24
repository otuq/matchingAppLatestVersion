//
//  ChatViewController.swift
//  matchingApp
//
//  Created by USER on 2020/11/18.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController:  UIViewController{

    private let cellId = "cellId"
    var anotherUser: User?
    var messages = [Message]()
    
    @IBOutlet weak var chatTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        settingView()
    }
    
    private func settingView(){
        chatTableView.delegate = self
        chatTableView.dataSource = self
    }
}
extension ChatViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)as! ChatTableViewCell
        cell.message = messages[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
}
