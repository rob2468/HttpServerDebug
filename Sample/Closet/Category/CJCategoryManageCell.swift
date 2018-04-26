//
//  CJCategoryManageCell.swift
//  Closet
//
//  Created by chenjun on 09/09/2017.
//  Copyright © 2017 chenjun. All rights reserved.
//

import UIKit

protocol CJCategoryManageCellDelegate: AnyObject {
    func onManageCellDeleteButtonPressed(_ cell: CJCategoryManageCell)
}

class CJCategoryManageCell: UICollectionViewCell {
    var nameLabel: UILabel!
    var deleteButton: UIButton!
    weak var delegate: CJCategoryManageCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1)
        
        // nameLabel
        self.nameLabel = UILabel()
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.textColor = UIColor.black
        self.nameLabel.font = UIFont.systemFont(ofSize: 14)
        self.contentView.addSubview(self.nameLabel)
        
        self.contentView.addConstraints(
            [NSLayoutConstraint.init(item: self.nameLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0),
             NSLayoutConstraint.init(item: self.nameLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -5)])
        
        // deleteButton
        self.deleteButton = UIButton.init(type: UIButtonType.custom)
        self.deleteButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteButton.setTitle("X", for: UIControlState.normal)
        self.deleteButton.setTitleColor(UIColor.red, for: UIControlState.normal)
        self.deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: UIControlEvents.touchUpInside)
        self.contentView.addSubview(self.deleteButton)
        
        self.contentView.addConstraints(
            [NSLayoutConstraint.init(item: self.deleteButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0),
             NSLayoutConstraint.init(item: self.deleteButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func deleteButtonPressed() -> Void {
        self.delegate?.onManageCellDeleteButtonPressed(self)
    }
}
