//
//  CJExhibitController.swift
//  Closet
//
//  Created by chenjun on 30/06/2017.
//  Copyright © 2017 chenjun. All rights reserved.
//
// 首页展示单品视图

import UIKit
private let kCollectionViewCellReuseIdentifier = "kCollectionViewCellReuseIdentifier"

class CJExhibitCollectionViewCell: UICollectionViewCell {
    
    var editButton: UIButton
    
    override init(frame: CGRect) {
        self.editButton = UIButton.init(type: UIButtonType.custom)

        super.init(frame: frame)
        self.backgroundColor = UIColor.yellow

        // editButton
        self.editButton.translatesAutoresizingMaskIntoConstraints = false
        self.editButton.setTitle("编辑", for: UIControlState.normal)
        self.editButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        self.editButton.isHidden = true;
        self.contentView.addSubview(self.editButton)
        
        self.contentView.addConstraints([
            NSLayoutConstraint.init(item: self.editButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -17),
            NSLayoutConstraint.init(item: self.editButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 20)])
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("")
        self.editButton = UIButton.init(type: UIButtonType.custom)
        super.init(coder: aDecoder);
    }
}

class CJExhibitController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var addProductButton: UIButton!                 // 添加单品按钮

    var dataList: [String] = ["a", "b", "c"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        // collectionView
        let frame = self.view.bounds
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        self.collectionView = UICollectionView.init(frame: frame, collectionViewLayout: flowLayout)
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
        self.collectionView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, .flexibleHeight]
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isPagingEnabled = true
        self.view.addSubview(self.collectionView)
        
        self.collectionView.register(CJExhibitCollectionViewCell.self, forCellWithReuseIdentifier: kCollectionViewCellReuseIdentifier)
        
        // addProductButton
        self.addProductButton = UIButton(type: UIButtonType.custom)
        self.addProductButton.translatesAutoresizingMaskIntoConstraints = false
        self.addProductButton.backgroundColor = UIColor.blue
        self.addProductButton.addTarget(self, action: #selector(addProductButtonPressed), for: UIControlEvents.touchUpInside)
        self.view.addSubview(self.addProductButton)
        
        let kAddProductButtonEdgeLength: CGFloat = 50
        self.addProductButton.layer.cornerRadius = kAddProductButtonEdgeLength / 2.0
        self.addProductButton.layer.shadowColor = UIColor.black.cgColor
        self.addProductButton.layer.shadowOpacity = 0.5
        self.addProductButton.layer.shadowOffset = CGSize.init(width: 0, height: 5)
        self.view.addConstraints(
            [NSLayoutConstraint.init(item: self.addProductButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -17),
             NSLayoutConstraint.init(item: self.addProductButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -17),
             NSLayoutConstraint.init(item: self.addProductButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 0, constant: kAddProductButtonEdgeLength),
             NSLayoutConstraint.init(item: self.addProductButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0, constant: kAddProductButtonEdgeLength)])
    }
    
    func addProductButtonPressed() {
        let addController = CJProductItemEditController.init(withProductItem: nil)
//        addController.delegate = self
        let rootController = CJRootController.fetchRootVC()
        rootController?.present(addController, animated: true, completion: nil)
    }
    
    // UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionViewCellReuseIdentifier, for: indexPath)
        
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.view.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
