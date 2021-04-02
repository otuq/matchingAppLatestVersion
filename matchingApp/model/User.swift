//
//  User.swift
//  matchingApp
//
//  Created by USER on 2022/1/26.
//  Copyright © 2022 otuq. All rights reserved.
//

import FirebaseFirestore
import UIKit

class User {
    let name: String
    let gender: String
    let age: String
    let location: String
    let imageUrl: String
    let introduction: String
    let creatAt: Timestamp
    let loginTime: Timestamp
    var anotherUid: String?
    var height: CGFloat?

    init(dic: [String: Any]) {
        name = dic["name"]as? String ?? ""
        gender = dic["gender"]as? String ?? ""
        age = dic["age"]as? String ?? ""
        location = dic["location"]as? String ?? ""
        imageUrl = dic["imageUrl"]as? String ?? ""
        introduction = dic["introduction"]as? String ?? ""
        creatAt = dic["creatAt"]as? Timestamp ?? Timestamp()
        loginTime = dic["loginTime"]as? Timestamp ?? Timestamp()
    }
}
