//
//  SignUpViewController.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/19.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageButton.layer.cornerRadius = 85
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        registerButton.layer.cornerRadius = 12
        
        //アクションをコードで実装する
        profileImageButton.addTarget(self, action: #selector(tappedProfileImageButton), for: .touchUpInside)
    }
    
    @objc private func tappedProfileImageButton() {
        print("tappedProfileImageButton")
        //アルバムが表示される
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }

}

//アルバムが表示される
extension SignUpViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    //写真をアルバムから選択した後の動き
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //編集してもしなくてもセットする
        if let editImage = info[.editedImage] as? UIImage {
            profileImageButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        //タイトルを空にする
        profileImageButton.setTitle("", for: .normal)
        //画像を丸型に合わせて表示
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.contentHorizontalAlignment = .fill
        profileImageButton.contentVerticalAlignment = .fill
        //領域外の画像を表示しない
        profileImageButton.clipsToBounds = true
        
        //閉じる
        dismiss(animated: true, completion: nil )
    }
}
