//
//  SearchCollectionViewCell.swift
//  matchingApp
//
//  Created by USER on 2022/1/30.
//  Copyright © 2022 otuq. All rights reserved.
//

import Nuke
import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    // MARK: - Property
    var anotherUser: User? {
        didSet {
            userNameLabel.text = anotherUser?.name ?? ""
            userGenderLabel.text = anotherUser?.gender ?? ""
            userAgeLabel.text = anotherUser?.age ?? ""
            userLocationLabel.text = anotherUser?.location ?? ""
            if let urlString = URL(string: anotherUser?.imageUrl ?? "") {
                Nuke.loadImage(with: urlString, into: userImageView)
            }
            userLoginTime.text = loginTimeCalculation(loginTime: anotherUser?.loginTime.dateValue() ?? Date())
            userMessageTextView.text = anotherUser?.introduction ?? ""
        }
    }
    // MARK: Outlets
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userMessageTextView: UITextView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userGenderLabel: UILabel!
    @IBOutlet var userAgeLabel: UILabel!
    @IBOutlet var userLocationLabel: UILabel!
    @IBOutlet var userLoginTime: UILabel!
    @IBOutlet var topStackView: UIStackView!
    @IBOutlet var bottomStackView: UIStackView!

    // MARK: - Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        bottomStackView.layer.shadowOffset = .init(width: 1, height: 1.5)
        bottomStackView.layer.shadowColor = UIColor.black.cgColor
        bottomStackView.layer.shadowOpacity = 0.3
        bottomStackView.layer.shadowRadius = 1
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        userImageView.contentMode = .scaleAspectFill
        userMessageTextView.layer.cornerRadius = 10
    }
    private func loginTimeCalculation(loginTime: Date) -> String {
        let timeInterval = Date().timeIntervalSince(loginTime)
        let time = Int(timeInterval)

        let day = time / 86_400
        let hour = time / 3_600 % 24
        let minute = time / 60 % 60
        let second = time % 60

        if day > 0 {
            return "ログイン:" + String(day) + "日前"
        } else if hour > 0 {
            return "ログイン:" + String(hour) + "時間前"
        } else if minute > 0 {
            return "ログイン:" + String(minute) + "分前"
        } else if second > 5 {
            return "ログイン:" + String(second) + "秒前"
        } else if second < 5 {
            return "ログイン:たった今"
        }
        return String()
    }
}
