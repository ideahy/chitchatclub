//
//  ChatRoomTableViewCell.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/16.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {

    //メッセージ幅に合わせてViewを可変にする
    var messageText:String? {
        //値を受けた際に計算をする
        didSet{
            guard let text = messageText else { return }
            //!!!!!デバイスによって可変にしたい!!!!!
            let width = estimateFrameForTextView(text: text).width + 20
            messageTextViewWidthConstraint.constant = width
            messageTextView.text = text
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    //メッセージ幅に合わせてViewを可変にする
    @IBOutlet weak var messageTextViewWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        userImageView.layer.cornerRadius = 30
        messageTextView.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //幅を調整するためのメソッド
    private func estimateFrameForTextView(text: String) -> CGRect {
        //マックス値の設定
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }
}
