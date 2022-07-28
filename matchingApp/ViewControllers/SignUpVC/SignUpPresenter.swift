//
//  SignUpPresenter.swift
//  matchingApp
//
//  Created by USER on 2022/07/19.
//  Copyright © 2022 otuq. All rights reserved.
//

import FirebaseAuth
import FirebaseStorage
import Foundation
import PKHUD
import UIKit

protocol SignUpInput {
    func saveFirestore()
}
class SignUpPresenter {
    private weak var output: SignUpOutput!
    init(with output: SignUpOutput) {
        self.output = output
    }
}
extension SignUpPresenter: SignUpInput {
    func saveFirestore() {
        HUD.show(.progress)
        guard let image = output.userInfoArray[.image]as? UIImage ?? UIImage(named: "tsuno"),
        let jpgData = image.jpegData(compressionQuality: 0.3) else { return }
        let userDefault = UserDefaults.standard
        let uuidString = NSUUID().uuidString
        // Profileのアップデートで使う
        userDefault.set(uuidString, forKey: "uuid")

        Storage.addImageStorage(uuidString: uuidString, jpgData: jpgData) { url in
            self.authenticationFirestore(url: url)
        }
    }
    private func authenticationFirestore(url: String) {
        // user情報
        Auth.signInRegister(userInfoArray: output.userInfoArray, imageUrl: url) { success in
            if success {
                print("登録保存の完了")
                HUD.hide()
                self.output.signUpReload()
            }
        }
    }
}
