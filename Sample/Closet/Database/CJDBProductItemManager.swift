//
//  CJDBProductItemManager.swift
//  Closet
//
//  Created by chenjun on 27/09/2017.
//  Copyright © 2017 chenjun. All rights reserved.
//

import UIKit

private let kImagePathValuesSeparator = ":"         // 单品数据库中，imagePath字段，多个值使用该分隔符间隔

class CJDBProductItemManager: NSObject {
    // 添加单品
    class func addProductItem(_ productItem: CJProductItemDataModel) {
        let databaseQueue = CJDBManager.sharedInstance.databaseQueue
        databaseQueue?.inDatabase({ (db) in
            let tableName = CJDBManager.kTABLEPRODUCT
            let nameField = CJDBManager.kPRODUCTFIELDNAME
            let priceField = CJDBManager.kPRODUCTFIELDPRICE
            let imagePathField = CJDBManager.kPRODUCTFIELDIMAGEPATH
            let name = productItem.name
            let price = productItem.price
            var imagePath: NSString?
            if let imagePaths = productItem.imagePath {
                imagePath = imagePaths.joined(separator: kImagePathValuesSeparator) as NSString
            }
            let stat = "INSERT INTO \(tableName) (\(nameField), \(priceField), \(imagePathField)) VALUES (?, ?, ?);"
            try? db.executeUpdate(stat, values: [name, price ?? NSNull(), imagePath ?? NSNull()])
        })
    }
}
