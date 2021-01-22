//
//  User.swift
//  matchingApp
//
//  Created by USER on 2020/11/26.
//  Copyright © 2020 otuq. All rights reserved.
//

import Foundation
import FirebaseFirestore

class User{
    let name: String
    let gender: String
    let age: String
    let location: String
    let imageUrl: String
    let creatAt: Timestamp
    
    var anotherUid: String?
    
    init(dic: [String: Any]) {
        name = dic["name"]as? String ?? ""
        gender = dic["gender"]as? String ?? ""
        age = dic["age"]as? String ?? ""
        location = dic["location"]as? String ?? ""
        imageUrl = dic["imageUrl"]as? String ?? ""
        creatAt = dic["creatAt"]as? Timestamp ?? Timestamp()
    }
}
