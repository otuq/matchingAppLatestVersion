//
//  ProfilePresenter.swift
//  matchingApp
//
//  Created by USER on 2022/07/27.
//  Copyright © 2022 otuq. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation

protocol ProfileInput {
    func fetchUserInfo()
    func updateStorage(image: UIImage?)
}
class ProfilePresenter {
    private weak var output: ProfileOutput!
    init(with output: ProfileOutput) {
        self.output = output
    }
}
extension ProfilePresenter: ProfileInput {
    func fetchUserInfo() {
        Firestore.getUserDocument { user in
            self.output.fetchUserInfo(user: user)
        }
    }
    func updateStorage(image: UIImage?) {
        let userDefault = UserDefaults.standard
        // StartUpVCで保存したuuidを取得
        guard let uuid = userDefault.string(forKey: "uuid"),
              let image = image,
              let jpgData = image.jpegData(compressionQuality: 0.3) else { return }

        Storage.updataImageUrl(jpgData: jpgData, child: uuid) { urlString in
            self.updateImageUrl(urlString: urlString)
        }
    }
    // 画像のimageUrlをupdate
    private func updateImageUrl(urlString: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let updateData = ["imageUrl": urlString]

        Firestore.updateFirestore(collection: .user, documentId: uid, updateData: updateData) {
            // ChatListに通知
            NotificationCenter.default.post(name: .profileUpdate, object: nil)
        }
    }
}
