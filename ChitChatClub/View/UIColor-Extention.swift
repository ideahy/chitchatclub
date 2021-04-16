//
//  UIColor-Extention.swift
//  ChitChatClub
//
//  Created by 山本英明 on 2021/04/16.
//


import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}


//import UIKit
//
//extension UIColor {
//    convenience init(hex: String, alpha: CGFloat = 1.0) {
//        let v = Int("000000" + hex, radix: 16) ?? 0
//        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
//        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
//        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
//        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
//    }
//}
