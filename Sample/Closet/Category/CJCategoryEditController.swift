//
//  CJCategoryEditController.swift
//  Closet
//
//  Created by chenjun on 21/08/2017.
//  Copyright © 2017 chenjun. All rights reserved.
//

import UIKit
private let kHeaderContentViewHeight = 64.0     // 头部引导视图高度

protocol CJCategoryEditControllerDelegate: AnyObject {
    func onCategoryEditControllerDismiss() -> Void
}

class CJCategoryEditController: UIViewController {
    // 视图
    var headerContentView: UIView!
    var categoryNameTextField: UITextField!
    
    weak var delegate: CJCategoryEditControllerDelegate?
    var category: CJCategoryDataModel?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(withCategory category: CJCategoryDataModel?) {
        self.init(nibName: nil, bundle: nil)
        self.category = category
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
        
        // titleLabel
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        self.headerContentView.addSubview(titleLabel)
        
        self.headerContentView.addConstraints([
            NSLayoutConstraint.init(item: titleLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.headerContentView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: titleLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.headerContentView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 10)])
        
        // "取消“
        let cancelButton = UIButton.init(type: UIButtonType.custom)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        cancelButton.setTitle("取消", for: UIControlState.normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: UIControlEvents.touchUpInside)
        self.headerContentView.addSubview(cancelButton)
        
        self.headerContentView.addConstraints([
            NSLayoutConstraint.init(item: cancelButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.headerContentView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 17),
            NSLayoutConstraint.init(item: cancelButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.headerContentView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 10)])
        
        // "保存"
        let doneButton = UIButton.init(type: UIButtonType.custom)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        doneButton.setTitle("保存", for: UIControlState.normal)
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: UIControlEvents.touchUpInside)
        self.headerContentView.addSubview(doneButton)
        
        self.headerContentView.addConstraints([
            NSLayoutConstraint.init(item: doneButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.headerContentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -17),
            NSLayoutConstraint.init(item: doneButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.headerContentView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 10)])
        
        // "分类名"
        let categoryNameLabel = UILabel()
        categoryNameLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryNameLabel.text = "分类名："
        categoryNameLabel.textColor = UIColor.black
        categoryNameLabel.font = UIFont.systemFont(ofSize: 17)
        self.view.addSubview(categoryNameLabel)
        
        categoryNameLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: UILayoutConstraintAxis.horizontal)
        self.view.addConstraints([
            NSLayoutConstraint.init(item: categoryNameLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 17),
            NSLayoutConstraint.init(item: categoryNameLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.headerContentView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 20)])
        
        // categoryNameTextField
        self.categoryNameTextField = UITextField()
        self.categoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        self.categoryNameTextField.borderStyle = UITextBorderStyle.roundedRect
        self.view.addSubview(self.categoryNameTextField)
        
        self.view.addConstraints([
            NSLayoutConstraint.init(item: self.categoryNameTextField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: categoryNameLabel, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self.categoryNameTextField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -17),
            NSLayoutConstraint.init(item: self.categoryNameTextField, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: categoryNameLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)])
        
        // 根据初识“分类”更新视图
        if let category = self.category {
            titleLabel.text = "更新分类"
            self.categoryNameTextField.text = category.name
        } else {
            titleLabel.text = "新增分类"
        }
    }

    func cancelButtonPressed() -> Void {
        self.delegate?.onCategoryEditControllerDismiss()
    }
    
    func doneButtonPressed() -> Void {
        var isSuccess = false
        // 解析用户输入
        var categoryName = self.categoryNameTextField.text
        categoryName = categoryName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let name = categoryName {
            if !name.isEmpty {
                if self.category == nil {
                    self.category = CJCategoryDataModel()
                }
                self.category!.name = name
                
                isSuccess = true
            }
        }
        
        if isSuccess {
            if self.category!.id == nil {
                // 新增分类
                CJDBCategoryManager.addCategory(self.category!)
            } else {
                // 更新分类
                CJDBCategoryManager.updateCategory(self.category!)
            }
            self.delegate?.onCategoryEditControllerDismiss()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
