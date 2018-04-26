//
//  CJDBCategoryManager.swift
//  Closet
//
//  Created by chenjun on 09/09/2017.
//  Copyright © 2017 chenjun. All rights reserved.
//

import UIKit

class CJDBCategoryManager: NSObject {
    
    // 获取所有“分类”
    class func fetchAllCategories(_: Void) -> [CJCategoryDataModel] {
        var dataList = [CJCategoryDataModel]()
        let databaseQueue = CJDBManager.sharedInstance.databaseQueue
        databaseQueue?.inDatabase({ (db) in
            let tableCategory = CJDBManager.kTABLECATEGORY
            let stat = "SELECT * FROM \(tableCategory);"
            let resultSet = try? db.executeQuery(stat, values: nil)
            if let rs = resultSet {
                let categoryFieldID = CJDBManager.kCATEGORYFIELDID
                let categoryFieldName = CJDBManager.kCATEGORYFIELDNAME
                while (rs.next()) {
                    let id = rs.long(forColumn: categoryFieldID)
                    let name = rs.string(forColumn: categoryFieldName)
                    
                    let category = CJCategoryDataModel()
                    category.id = id
                    if let n = name {
                        category.name = n
                    }
                    dataList.append(category)
                }
                rs.close()
            }
        })
        return dataList
    }
    
    // 添加“分类”
    class func addCategory(_ category: CJCategoryDataModel) {
        let databaseQueue = CJDBManager.sharedInstance.databaseQueue
        databaseQueue?.inDatabase({ (db) in
            let tableName = CJDBManager.kTABLECATEGORY
            let nameField = CJDBManager.kCATEGORYFIELDNAME
            let name = category.name
            let stat = "INSERT INTO \(tableName) (\(nameField)) VALUES ('\(name)');"
            try? db.executeUpdate(stat, values: nil)
        })
    }
    
    // 更新“分类”
    class func updateCategory(_ category: CJCategoryDataModel) {
        let databaseQueue = CJDBManager.sharedInstance.databaseQueue
        databaseQueue?.inDatabase({ (db) in
            let tableName = CJDBManager.kTABLECATEGORY
            let idField = CJDBManager.kCATEGORYFIELDID
            let nameField = CJDBManager.kCATEGORYFIELDNAME
            let id = category.id!
            let name = category.name
            let stat = "UPDATE \(tableName) SET \(nameField) = '\(name)' WHERE \(idField) = \(id);"
            try? db.executeUpdate(stat, values: nil)
        })
    }
    
    // 删除指定“分类”
    class func deleteCategory(withID id: Int) {
        let databaseQueue = CJDBManager.sharedInstance.databaseQueue
        databaseQueue?.inDatabase({ (db) in
            let tableCategory = CJDBManager.kTABLECATEGORY
            let categoryFieldID = CJDBManager.kCATEGORYFIELDID
            let stat = "DELETE FROM \(tableCategory) WHERE \(categoryFieldID) = \(id);"
            try? db.executeUpdate(stat, values: nil)
        })
    }
}
