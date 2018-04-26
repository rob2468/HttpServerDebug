//
//  CJProductItemDataModel.swift
//  Closet
//
//  Created by chenjun on 26/09/2017.
//  Copyright © 2017 chenjun. All rights reserved.
//
//  "单品“数据模型

import UIKit

class CJProductItemDataModel: NSObject {
    var id: Int?                    // 唯一标识符
    var name: String = ""           // 单品名称
    var price: Double?              // 价格
    var imagePath: [String]?        // 照片本地存放路径（第一张图片为默认图片）
}
