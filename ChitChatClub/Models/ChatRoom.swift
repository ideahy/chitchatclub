//
//  ChatRoom.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/20.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatRoom {
    let latestMessageId: String
    let members: [String]
    let createdAt: Timestamp
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
