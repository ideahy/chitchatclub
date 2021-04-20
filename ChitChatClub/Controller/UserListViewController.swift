//
//  UserListViewController.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/20.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class UserListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var users = [User]()

    @IBOutlet weak var userListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListTableView.delegate = self
        userListTableView.dataSource = self
    }
    
    private func fetchUserInfoFromFirestore() {
       //Firestoreから保存されている値をフェッチ
       Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
           if let err = err{
               print("user情報の取得に失敗しました。\(err)")
               return
           }
           snapshots?.documents.forEach({ (snapshot) in
               let dic = snapshot.data()
               //フェッチしたdata(dic)をuserに変換
               let user = User.init(dic: dic)
               self.users.append(user)
               self.userListTableView.reloadData()
               //念の為確認(ユーザーネームだけ表示する)
               self.users.forEach { (user) in
                   print("user.username: ", user.username)
               }
           })
       }
   }
}

extension UserListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        return cell
    }
}


//Firestoreから取得した画像URLを変換して表示するライブラリを利用する
class UserListTableViewCell: UITableViewCell {
    
    var user: User? {
        didSet{
            usernameLabel.text = user?.username
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
