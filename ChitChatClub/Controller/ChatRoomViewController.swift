//
//  ChatRoomViewController.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/16.
//

import UIKit

class ChatRoomViewController: UIViewController {
    
    private let cellId = "cellId"
    
    //入力用Viewをインスタンス化
    private var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        return view
    }()
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        //別ファイルで記述した場合はregisterが必要
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
    }
    
    //入力用Viewインスタンス → 元々あるinputAccessoryViewプロパティをオーバーライドする
    override var inputAccessoryView: UIView?{
        get {
            return chatInputAccessoryView
        }
    }
    
    //もう一つ、元々あるプロパティをオーバーライドする
    override var canBecomeFirstResponder: Bool{
        return true
    }
}


extension ChatRoomViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        return cell
    }
}
