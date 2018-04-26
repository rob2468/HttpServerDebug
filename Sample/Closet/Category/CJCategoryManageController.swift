//
//  CJCategoryManageController.swift
//  Closet
//
//  Created by chenjun on 21/08/2017.
//  Copyright © 2017 chenjun. All rights reserved.
//

import UIKit
private let kHeaderContentViewHeight = 64.0     // 头部引导视图高度
private let kFooterContentViewHeight = 44.0
private let kAddButtonEdgeLength = 34.0
private let kCollectionViewCellReuseIdentifier = "kCollectionViewCellReuseIdentifier"

class CJCategoryManageController: UIViewController, CJCategoryEditControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CJCategoryManageCellDelegate {

    var headerContentView: UIView!
    var footerContentView: UIView!
    var collectionView: UICollectionView!
    var dataList: [CJCategoryDataModel]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.dataList = CJDBCategoryManager.fetchAllCategories()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        // headerContentView
        self.headerContentView = UIView()
        var frame = self.view.bounds
        frame.size.height = CGFloat(kHeaderContentViewHeight)
        self.headerContentView.frame = frame
        self.headerContentView.backgroundColor = UIColor.lightGray
        self.view.addSubview(self.headerContentView)
        
        // “分类管理”
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.text = "分类管理"
        titleLabel.textColor = UIColor.white
        self.headerContentView.addSubview(titleLabel)
        
        self.view.addConstraints([
            NSLayoutConstraint.init(item: titleLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: headerContentView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: titleLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: headerContentView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 10)])
        
        // "完成"
        let doneButton = UIButton.init(type: UIButtonType.custom)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        doneButton.setTitle("完成", for: UIControlState.normal)
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: UIControlEvents.touchUpInside)
        self.headerContentView.addSubview(doneButton)
        
        self.view.addConstraints([
            NSLayoutConstraint.init(item: doneButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: headerContentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -17),
            NSLayoutConstraint.init(item: doneButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: titleLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)])
        
        // footerContentView
        self.footerContentView = UIView()
        frame = self.view.frame
        frame.origin.y = frame.size.height - CGFloat(kFooterContentViewHeight)
        frame.size.height = CGFloat(kFooterContentViewHeight)
        self.footerContentView.frame = frame
        self.footerContentView.backgroundColor = UIColor.clear
        self.view.addSubview(self.footerContentView)
        
        // addButton
        let addButton = UIButton.init(type: UIButtonType.custom)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        let addButtonColor = UIColor.black
        addButton.layer.borderColor = addButtonColor.cgColor
        addButton.layer.borderWidth = 1.0
        addButton.layer.cornerRadius = CGFloat(kAddButtonEdgeLength / 2.0)
        addButton.setTitleColor(addButtonColor, for: UIControlState.normal)
        addButton.setTitle("+", for: UIControlState.normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 25.0)
        addButton.addTarget(self, action: #selector(addButtonPressed), for: UIControlEvents.touchUpInside)
        self.footerContentView.addSubview(addButton)
        
        self.footerContentView.addConstraints([
            NSLayoutConstraint.init(item: addButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.footerContentView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: addButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.footerContentView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: addButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.footerContentView, attribute: NSLayoutAttribute.width, multiplier: 0, constant: CGFloat(kAddButtonEdgeLength)),
            NSLayoutConstraint.init(item: addButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.footerContentView, attribute: NSLayoutAttribute.height, multiplier: 0, constant: CGFloat(kAddButtonEdgeLength))])
        
        // collectionView
        frame = self.view.bounds
        frame.origin.y = CGFloat(kHeaderContentViewHeight)
        frame.size.height -= CGFloat(kHeaderContentViewHeight + kFooterContentViewHeight)
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        self.collectionView = UICollectionView.init(frame: frame, collectionViewLayout: flowLayout)
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(self.collectionView)
        
        self.collectionView.register(CJCategoryManageCell.self, forCellWithReuseIdentifier: kCollectionViewCellReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    /// 重新读取分类数据，并刷新视图
    func reloadCollectionView() {
        self.dataList = CJDBCategoryManager.fetchAllCategories()
        self.collectionView.reloadData()
    }
    
    func doneButtonPressed() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addButtonPressed() -> Void {
        self.showCategoryEditVC(nil)
    }
    
    func showCategoryEditVC(_ category: CJCategoryDataModel?) {
        let addController = CJCategoryEditController.init(withCategory: category)
        addController.delegate = self
        let rootController = CJRootController.fetchRootVC()
        rootController?.present(addController, animated: true, completion: nil)
    }
    
    // MARK: CJCategoryEditControllerDelegate
    
    func onCategoryEditControllerDismiss() {
        // 移除添加分类视图
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController?.dismiss(animated: true, completion: nil)
        
        // 重新加载数据并更新视图
        self.reloadCollectionView()
    }
    
    // MARK: UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionViewCellReuseIdentifier, for: indexPath) as! CJCategoryManageCell
        cell.delegate = self
        
        let item = indexPath.item
        let category = self.dataList[item]
        cell.nameLabel.text = category.name
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let idx = indexPath.item
        let category = self.dataList[idx]
        self.showCategoryEditVC(category)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let top = 10.0
        let left = 17.0
        let bottom = 10.0
        let right = 17.0
        return UIEdgeInsetsMake(CGFloat(top), CGFloat(left), CGFloat(bottom), CGFloat(right))
    }
    
    // MARK: CJCategoryManageCellDelegate
    
    func onManageCellDeleteButtonPressed(_ cell: CJCategoryManageCell) {
        let idxPath = self.collectionView.indexPath(for: cell)
        if let indexPath = idxPath {
            // 获取分类
            let item = indexPath.item
            let category = self.dataList[item]
            let id = category.id
            let name = category.name
            
            // 二次确认
            let alert = UIAlertController.init(title: nil, message: "确定删除分类“\(name)”？", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: { (action) in
                return
            })
            alert.addAction(cancelAction)
            let confirmAction = UIAlertAction.init(title: "确定", style: UIAlertActionStyle.destructive, handler: { (action) in
                if let localID = id {
                    // 删除数据库中指定分类
                    CJDBCategoryManager.deleteCategory(withID:localID)
                    // 删除内存中指定分类
                    self.dataList.remove(at: item)
                    // 更新视图
                    self.collectionView.deleteItems(at: [indexPath])
                }
            })
            alert.addAction(confirmAction)
            let rootController = CJRootController.fetchRootVC()
            rootController?.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
