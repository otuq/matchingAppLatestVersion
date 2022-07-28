//
//  SearchPresenter.swift
//  matchingApp
//
//  Created by USER on 2022/07/19.
//  Copyright © 2022 otuq. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

protocol SearchInput {
    func authSignIn()
    func authSignout()
    func whenNewUser()
    func fetchAnotherUserInfo(complition: @escaping (User) -> Void)
}
class SearchPresenter {
    private weak var output: SearchOutput!
    init(with output: SearchOutput) {
        self.output = output
    }
}
extension SearchPresenter: SearchInput {
    func authSignIn() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let updateData = ["loginTime": Timestamp()] as [String: Any]
        Firestore.updateFirestore(collection: .user, documentId: uid, updateData: updateData)
    }
    func authSignout() {
        do {
            try Auth.auth().signOut()
            self.whenNewUser()
        } catch {
            print(error)
        }
    }
    func whenNewUser() {
        if Auth.auth().currentUser?.uid == nil {
            output.transitionSignUpVC()
        }
    }
    func fetchAnotherUserInfo(complition: @escaping (User) -> Void) {
        Firestore.getAllAnotherUserDocuments {
            self.output.reloadData()
        } complition: { anotherUser in
            complition(anotherUser)
        }
    }
}
