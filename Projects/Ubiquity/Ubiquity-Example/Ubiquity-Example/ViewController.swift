//
//  ViewController.swift
//  Ubiquity-Example
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import Ubiquity

import WebKit

class ViewController: UITableViewController, UIActionSheetDelegate {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func show(_ sender: Any) {
//        let sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
////        
////        sheet.addButton(withTitle: "Browser")
////        sheet.addButton(withTitle: "Picker")
////        sheet.addButton(withTitle: "Editor")
////        
////        sheet.show(in: self.view)
//        
//        // skip
//        actionSheet(sheet, clickedButtonAt: 1)
        
//        let html = "<html><meta charset=\"utf8\"/><style>.t{width:240px;color: #454545;font-size: 14px;vertical-align:top;}.d{align:left;color: #858585;}</style><body><table><tr><td class='t'>公司全称：</td><td class='d'>烟台同立高科新材料股份有限公司</td></tr><tr><td class='t'>英文名称：</td><td class='d'>Yantai Tomley Hi-tech Advanced Materials Co., Ltd.</td></tr><tr><td class='t'>注册地址：</td><td class='d'>山东省烟台市福山区英特尔大道20号</td></tr><tr><td class='t'>法人代表：</td><td class='d'>郭大为</td></tr><tr><td class='t'>董事长：</td><td class='d'>郭大为</td></tr><tr><td class='t'>公司董秘：</td><td class='d'>刘颖</td></tr><tr><td class='t'>注册资本：</td><td class='d'>7030</td></tr><tr><td class='t'>行业分类：</td><td class='d'>化学原料及化学制品制造业</td></tr><tr><td class='t'>投资概念：</td><td class='d'>(null)</td></tr><tr><td class='t'>挂牌日期：</td><td class='d'>2014-01-24</td></tr><tr><td class='t'>转让方式：</td><td class='d'>协议</td></tr><tr><td class='t'>公司网址：</td><td class='d'>www.tomley.com</td></tr><tr><td class='t'>主营业务：</td><td class='d'>纳米材料的制造,陶瓷粉末及陶瓷制品的研发、生产和销售。货物、技术的进出口业务(国家禁止的除外)。</td></tr><tr><td class='t'>主要产品：</td><td class='d'>氮化物系列粉体及氮化物系列陶瓷制品等无机非金属新材料</td></tr></table></body></html>"
//
//        let label = UILabel(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 480))
//        var dic: NSDictionary? = [
//            NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType
//        ]
//        label.attributedText = try? NSAttributedString(data: html.data(using: .utf8)!, options: [:], documentAttributes: &dic)
//        label.numberOfLines = 0
//        tableView.tableHeaderView = label
//        
//        let wv  = WKWebView(frame: .init(x: 0, y: 0, width: view.bounds.width, height: 480))
//        wv.loadHTMLString(html, baseURL: nil)
//        tableView.tableHeaderView = wv
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        guard buttonIndex != actionSheet.cancelButtonIndex else {
            return
        }
//        switch buttonIndex {
//        case 1:
//            let browser = Ubiquity.Browser()
//            ub_present(browser, animated: true, completion: nil)
//            
////        case 2:
////            let browser = Ubiquity.Picker()
////            present(browser, animated: true, completion: nil)
////            
////        case 3:
////            let browser = Ubiquity.Picker()
////            present(browser, animated: true, completion: nil)
////            
//        default:
//            break
//        }
    }
}

