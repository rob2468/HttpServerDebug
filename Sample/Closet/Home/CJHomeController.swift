//
//  CJHomeController.swift
//  Closet
//
//  Created by chenjun on 30/06/2017.
//  Copyright © 2017 chenjun. All rights reserved.
//
// 首页

import UIKit

class CJHomeController: UIViewController, CJCategoryControllerDelegate {
    
    var expandButton: UIButton!                     // 展开分类面板按钮
    var exhibitController: CJExhibitController!     // 单品展示视图控制器
    var categoryController: CJCategoryController!   // 分类面板视图控制器

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
        self.view.backgroundColor = UIColor.white
        
        // exhibitController
        self.exhibitController = CJExhibitController()
        self.exhibitController.view.frame = self.view.bounds
        self.exhibitController.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.exhibitController.view)
        self.addChildViewController(self.exhibitController)

        // expandButton
        self.expandButton = UIButton(type: UIButtonType.custom)
        self.expandButton.translatesAutoresizingMaskIntoConstraints = false
        self.expandButton.setTitle("展开分类", for: UIControlState.normal)
        self.expandButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.expandButton.setTitleColor(UIColor.black.withAlphaComponent(0.2), for: UIControlState.highlighted)
        self.expandButton.addTarget(self, action: #selector(expandButtonPressed), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.expandButton);
        
        self.view.addConstraints([
            NSLayoutConstraint.init(item: self.expandButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 17),
            NSLayoutConstraint.init(item: self.expandButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 20)])
    }
    
    func expandButtonPressed() -> Void {
        // 显示分类面板
        self.categoryController = CJCategoryController()
        self.categoryController.delegate = self
        self.categoryController.view.frame = self.view.bounds
        self.categoryController.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.categoryController.view)
        self.addChildViewController(self.categoryController)
    }
    
    // MARK: CJCategoryControllerDelegate
    
    func closePannel() {
        // 关闭分类面板
        self.categoryController.view.removeFromSuperview()
        self.categoryController = nil
    }
    
    func showCategoryManage() {
        let manageController = CJCategoryManageController()
        self.navigationController?.pushViewController(manageController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
