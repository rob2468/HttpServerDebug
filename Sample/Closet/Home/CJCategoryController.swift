//
//  CJCategoryController.swift
//  Closet
//
//  Created by chenjun on 30/06/2017.
//  Copyright © 2017 chenjun. All rights reserved.
//
// 首页分类面板

import UIKit
private let kPannelViewWidth = 280.0            // 分类面板宽度
private let kHeaderContentViewHeight = 64.0     // 头部引导视图高度
private let kCJCategoryTableViewCellReuseIdentifier = "kCJCategoryTableViewCellReuseIdentifier"

@objc protocol CJCategoryControllerDelegate {
    func closePannel() -> Void
    func showCategoryManage() -> Void
}

class CJCategoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var pannelView: UIView!
    var headerContentView: UIView!
    var tableView: UITableView!
    
    var closeButton: UIButton!
    var delegate: CJCategoryControllerDelegate?
    var dataList = [CJCategoryDataModel]()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // 数据库检索所有分类
        self.dataList = CJDBCategoryManager.fetchAllCategories()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        // pannelView
        self.pannelView = UIView()
        var frame = self.view.bounds
        frame.origin.x = -(CGFloat)(kPannelViewWidth)
        frame.size.width = CGFloat(kPannelViewWidth)
        self.pannelView.frame = frame
        self.pannelView.backgroundColor = UIColor.white
        self.pannelView.autoresizingMask = UIViewAutoresizing.flexibleRightMargin
        self.view.addSubview(self.pannelView)
        
        // headerContentView
        self.headerContentView = UIView()
        frame = self.pannelView.bounds
        frame.size.height = CGFloat(kHeaderContentViewHeight)
        self.headerContentView.frame = frame
        self.headerContentView.backgroundColor = UIColor.lightGray
        self.pannelView.addSubview(self.headerContentView)
        
        // “分类”
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.text = "分类"
        titleLabel.textColor = UIColor.white
        self.headerContentView.addSubview(titleLabel)
        
        self.headerContentView.addConstraints([
            NSLayoutConstraint.init(item: titleLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.headerContentView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: titleLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.headerContentView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 10)])
        
        // “管理“
        let manageButton = UIButton.init(type: UIButtonType.custom)
        manageButton.translatesAutoresizingMaskIntoConstraints = false
        manageButton.setTitle("管理", for: UIControlState.normal)
        manageButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        manageButton.addTarget(self, action: #selector(manageButtonPressed), for: UIControlEvents.touchUpInside)
        self.headerContentView.addSubview(manageButton)
        
        self.headerContentView.addConstraints([
            NSLayoutConstraint.init(item: manageButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.headerContentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -17),
            NSLayoutConstraint.init(item: manageButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: titleLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)])
        
        // tableView
        self.tableView = UITableView()
        frame = self.pannelView.bounds
        frame.origin.y = CGFloat(kHeaderContentViewHeight)
        frame.size.height -= CGFloat(kHeaderContentViewHeight)
        self.tableView.frame = frame
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.pannelView.addSubview(self.tableView)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCJCategoryTableViewCellReuseIdentifier)
        
        // closeButton
        self.closeButton = UIButton.init(type: UIButtonType.custom)
        self.closeButton.backgroundColor = UIColor.clear
        frame = self.view.bounds
        frame.origin.x = CGFloat(kPannelViewWidth)
        frame.size.width -= CGFloat(kPannelViewWidth)
        self.closeButton.frame = frame;
        self.closeButton.addTarget(self, action: #selector(closeButtonPressed), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.closeButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) { 
            // 渐现
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            // 平移
            var frame = self.pannelView.frame
            frame.origin.x = 0
            self.pannelView.frame = frame
        }
    }
    
    func closeButtonPressed() {
        UIView.animate(withDuration: 0.2, animations: { 
            // 渐隐
            self.view.backgroundColor = UIColor.clear
            // 平移
            var frame = self.pannelView.frame
            frame.origin.x = -(CGFloat)(kPannelViewWidth)
            self.pannelView.frame = frame
        }) { (Bool) in
            self.delegate?.closePannel()
        }
    }
    
    func manageButtonPressed() {
        self.delegate?.closePannel()
        self.delegate?.showCategoryManage()
    }
    
    // UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCJCategoryTableViewCellReuseIdentifier, for: indexPath)
        let row = indexPath.row
        let category = self.dataList[row]
        cell.textLabel?.text = category.name
        return cell
    }
    
    // UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
