//
//  SearchCollectionViewCell.swift
//  matchingApp
//
//  Created by USER on 2020/11/30.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import Nuke

class SearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userMessageTextView: UITextView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userGenderLabel: UILabel!
    @IBOutlet weak var userAgeLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userLoginTime: UILabel!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    
    //
    var anotherUser: User?{
        didSet{
            userNameLabel.text = anotherUser?.name ?? "名前"
            userGenderLabel.text = anotherUser?.gender ?? "性別"
            userAgeLabel.text = anotherUser?.age ?? "歳"
            userLocationLabel.text = anotherUser?.location ?? "場所"
            if let urlString = URL(string: anotherUser?.imageUrl ?? ""){
                Nuke.loadImage(with: urlString, into: userImageView)
            }
            userLoginTime.text = loginTimeCalculation(loginTime: anotherUser?.creatAt.dateValue() ?? Date())
            var message = ""
            for _ in 0...20{
                let name = anotherUser?.name ?? "名前"
                message += name
            }
            userMessageTextView.text = message
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.bounds.width/2
        userImageView.contentMode = .scaleAspectFill
        userMessageTextView.layer.cornerRadius = 10
        //        let height = self.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        //        arrayHeight?.append(height)
        //        print(arrayHeight ?? 0)
        
    }
    
    
    
    private func loginTimeCalculation(loginTime: Date)->String{
        let timeInterval = Date().timeIntervalSince(loginTime)
        let time = Int(timeInterval)
        
        let day = time / 86400
        let hour = time / 3600 % 24
        let minute = time / 60 % 60
        let second = time % 60
        
        if 0 < day {
            return "ログイン:"+String(day)+"日前"
        }else if 0 < hour{
            return "ログイン:"+String(hour)+"時間前"
        }else if 0 < minute{
            return "ログイン:"+String(minute)+"分前"
        }else if 5 < second{
            return "ログイン:"+String(second)+"秒前"
        }else if second < 5{
            return "ログイン:たった今"
        }
        return String()
    }
}
