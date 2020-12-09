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
    
    var anotherUser: User?{
        didSet{
            userNameLabel.text = anotherUser?.name ?? "名前"
            userGenderLabel.text = anotherUser?.gender ?? "性別"
            userAgeLabel.text = anotherUser?.age ?? "歳"
            userLocationLabel.text = anotherUser?.location ?? "場所"
            if let urlString = URL(string: anotherUser?.imageUrl ?? ""){
                Nuke.loadImage(with: urlString, into: userImageView)
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.bounds.width/2
        userImageView.contentMode = .scaleAspectFill
        userMessageTextView.layer.cornerRadius = 10
    }

    
}
