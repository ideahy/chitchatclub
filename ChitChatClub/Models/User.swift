//
//  User.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/19.
//

import Foundation
import Firebase
import FirebaseFirestore

class User {
    
    let email: String
    let username: String
    let createdAt: Timestamp
    let profileImageUrl: String
    
    var uid: String?
    
    //上記の引数をもとにUser配列を作成
    init(dic: [String: Any]) {
        //??はnilだった場合の条件
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
    }
}
