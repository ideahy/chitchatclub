//
//  SignUpViewController.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/19.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

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
        registerButton.addTarget(self, action: #selector(tappedRegisterButton), for: .touchUpInside)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
        //初期はボタン押せない
        registerButton.isEnabled = false
        registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
    }
    
    @objc private func tappedProfileImageButton() {
        //アルバムが表示される
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }

    @objc private func tappedRegisterButton() {
        //画像をStorageに保存する
        guard let image = profileImageButton.imageView?.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("FireStorageへの情報の保存に失敗しました。\(err)")
                return
            }
            print("FireStorageへの情報の保存に成功しました。")
            storageRef.downloadURL { (url, err) in
                if let err = err {
                    print("Firestoreからのurlのダウンロードに失敗しました。\(err)")
                    return
                }
                print("Firestoreからのurlのダウンロードに成功しました。")
                guard let urlString = url?.absoluteString else { return }
                print("urlString: ", urlString)
                self.createUserToFirestore(profileImageUrl: urlString)
            }
        }
    }
    
    private func createUserToFirestore(profileImageUrl: String) {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("認証情報の保存に失敗しました。\(err)")
                return
            }
            print("認証情報の保存に成功しました。")
            //ユーザー情報をFSに保存する
            //UID
            guard let uid = res?.user.uid else { return }
            guard let username = self.usernameTextField.text else { return }
            //email,username,date
            let docData = [
                "email": email,
                "username": username,
                "createdAt": Timestamp(),
                "profileImageUrl": profileImageUrl
            ] as [String : Any]
            Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                if let err = err {
                    print("Firestoreへの保存に失敗しました。\(err)")
                    return
                }
                print("Firestoreへの情報の保存が成功しました。")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

//
extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //textField全てに適用
        let emailIsEmpty = emailTextField.text?.isEmpty ?? false
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? false
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? false
        //一つでも空があるとボタンを押せなくする
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 0, green: 185, blue: 0)
        }
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
