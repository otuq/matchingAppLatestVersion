//
//  ConfigurePresenter.swift
//  matchingApp
//
//  Created by USER on 2022/07/27.
//  Copyright © 2022 otuq. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

protocol ConfigureInput {
    func updateConfigure(updateData: [AnyHashable: Any])
}
class ConfigurePresenter {
    private weak var output: ConfigureOutput!
    init(with output: ConfigureOutput) {
        self.output = output
    }
}
extension ConfigurePresenter: ConfigureInput {
    func updateConfigure(updateData: [AnyHashable: Any]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.updateFirestore(collection: .user, documentId: uid, updateData: updateData) {
            self.output.profileVCReloadAndDismiss()
        }
    }
}
