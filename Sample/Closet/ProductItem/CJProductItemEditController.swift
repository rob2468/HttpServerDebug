//
//  CJProductItemEditController.swift
//  Closet
//
//  Created by chenjun on 26/09/2017.
//  Copyright © 2017 chenjun. All rights reserved.
//

import UIKit
private let kHeaderContentViewHeight = 64.0     // 头部引导视图高度

protocol CJProductItemEditControllerDelegate: AnyObject {
    func onProductItemEditControllerDismiss() -> Void
}

class CJProductItemEditController: UIViewController {

    var headerContentView: UIView!          // 头部
    var scrollView: UIScrollView!
    var contentView: UIView!                // 内容
    var nameTextField: UITextField!         // 单品名称输入框
    weak var delegate: CJProductItemEditControllerDelegate?
    var productItem: CJProductItemDataModel?

    convenience init(withProductItem productItem: CJProductItemDataModel?) {
        self.init(nibName: nil, bundle: nil)
        self.productItem = productItem
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
        
        // scrollView
        self.scrollView = UIScrollView.init()
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.backgroundColor = UIColor.white
        self.view.addSubview(self.scrollView);
        
        // contentView
        self.contentView = UIView.init()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.backgroundColor = UIColor.white
        self.scrollView.addSubview(self.contentView)
        
        self.view.addConstraints(
            [NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0),
             NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0),
             NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.headerContentView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0),
             NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)])
        self.view.addConstraints(
            [NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0),
             NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0),
             NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0),
             NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)])
        self.view.addConstraints(
            [NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0),
             NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)])
        
        // "单品名"
        let productItemNameLabel = UILabel()
        productItemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        productItemNameLabel.text = "单品名："
        productItemNameLabel.textColor = UIColor.black
        productItemNameLabel.font = UIFont.systemFont(ofSize: 17)
        self.contentView.addSubview(productItemNameLabel)
        
        productItemNameLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: UILayoutConstraintAxis.horizontal)
        self.view.addConstraints([
            NSLayoutConstraint.init(item: productItemNameLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 17),
            NSLayoutConstraint.init(item: productItemNameLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 20)])
        
        // nameTextField
        self.nameTextField = UITextField()
        self.nameTextField.translatesAutoresizingMaskIntoConstraints = false
        self.nameTextField.borderStyle = UITextBorderStyle.roundedRect
        self.contentView.addSubview(self.nameTextField)
        
        self.view.addConstraints([
            NSLayoutConstraint.init(item: self.nameTextField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: productItemNameLabel, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self.nameTextField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -17),
            NSLayoutConstraint.init(item: self.nameTextField, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: productItemNameLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)])
        
        // contentView设置bottom约束
        self.view.addConstraints(
            [NSLayoutConstraint.init(item: self.contentView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: productItemNameLabel, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 20)])

        if let localProductItem = self.productItem {
            titleLabel.text = "更新单品"
        } else {
            titleLabel.text = "添加单品"
        }
    }
    
    func cancelButtonPressed() -> Void {
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        rootController?.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonPressed() -> Void {
        var isSuccess = false
        // 解析用户输入
        var name = self.nameTextField.text
        name = name?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let productName = name {
            if !productName.isEmpty {
                if self.productItem == nil {
                    self.productItem = CJProductItemDataModel()
                }
                self.productItem!.name = productName;
                
                isSuccess = true
            }
        }
        
        if isSuccess {
            if self.productItem!.id == nil {
                // 新增单品
                CJDBProductItemManager.addProductItem(self.productItem!)
            } else {
                // 更新单品
                
            }
            
            // 退出当前页面
            let rootController = UIApplication.shared.keyWindow?.rootViewController
            rootController?.dismiss(animated: true, completion: nil)
        } 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
