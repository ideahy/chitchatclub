//
//  UserListViewController.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/20.
//

import UIKit

class UserListViewController: UIViewController {
    
    private let cellId = "cellId"

    @IBOutlet weak var userListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userListTableView.delegate = self
        userListTableView.dataSource = self
        
        //
        userListTableView.register(UITableView.self, forCellReuseIdentifier: cellId)
    }
}

extension UserListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        return cell
    }
}
