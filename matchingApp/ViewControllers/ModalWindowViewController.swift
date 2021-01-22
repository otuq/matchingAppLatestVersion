//
//  ModalWindowViewController.swift
//  matchingApp
//
//  Created by USER on 2020/12/07.
//  Copyright © 2020 otuq. All rights reserved.
//

import UIKit
import FirebaseFirestore

protocol PhotoEditDelegate: class {
    func tapActionPhotoEdit(edit: String)
}

class ModalWindowViewController: UIViewController {
    
    weak var delegate: PhotoEditDelegate?
    
    @IBOutlet weak var profileStuckView: UIStackView!
    
    @IBAction func photoEditButton(_ sender: Any) {
        self.dismiss(animated: true) {
            let edit = "photo"
            self.delegate?.tapActionPhotoEdit(edit: edit)
        }
    }
        
    @IBAction func profileEditButton(_ sender: Any) {
        self.dismiss(animated: true) {
            let edit = "profile"
            self.delegate?.tapActionPhotoEdit(edit: edit)
        }
        
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil
        )
    }
}

