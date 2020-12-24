//
//  ChatInputAccessory.swift
//  matchingApp
//
//  Created by USER on 2020/12/15.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit

class ChatInputAccessory: UIView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        settingInputAccessory()
        autoresizingMask = .flexibleHeight
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func nibInit(){
        let nib = UINib.init(nibName: "ChatInputAccessory", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.addSubview(view)
    }
    private func settingInputAccessory(){
        
    }
    private func removeMessage(){
        
    }
    override var intrinsicContentSize: CGSize {
        return .zero
    }
}
