//
//  CJDBManager.swift
//  Closet
//
//  Created by chenjun on 09/08/2017.
//  Copyright © 2017 chenjun. All rights reserved.
//

import UIKit

private let kCurrentVersion = 1

class CJDBManager: NSObject {
    static let sharedInstance = CJDBManager()
    // 表名
    static let kTABLECATEGORY = "category"
    static let kTABLEPRODUCT = "product"
    // 字段名
    static let kCATEGORYFIELDID = "id"
    static let kCATEGORYFIELDNAME = "name"
    static let kPRODUCTFIELDID = "id"
    static let kPRODUCTFIELDNAME = "name"
    static let kPRODUCTFIELDPRICE = "price"
    static let kPRODUCTFIELDIMAGEPATH = "image_path"

    var dbFilePath: URL!
    var databaseQueue: FMDatabaseQueue!
    
    private override init() {
        super.init()
        self.dbFilePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Closet.sqlite")
        self.databaseQueue = FMDatabaseQueue.init(url: self.dbFilePath)
        // 读取数据库版本号
        var version = 0
        self.databaseQueue.inDatabase { (db: FMDatabase)->Void in
            let rs = try? db.executeQuery("PRAGMA user_version", values: nil)
            if let resultSet = rs {
                if resultSet.next() {
                    version = Int(resultSet.int(forColumnIndex: 0))
                }
                resultSet.close()
            }
        }
        guard version <= kCurrentVersion else {
            return
        }
        // 数据库升级
        self.upgradeDatabaseFromVersion(version)
    }
    
    func upgradeDatabaseFromVersion(_ version: Int) -> Void {
        // 数据库逐版本升级
        for i in version..<kCurrentVersion {
            if i == 0 {
                self.databaseQueue.inTransaction({ (db, rollback) in
                    // 创建“分类”表
                    var stat = "CREATE TABLE \(CJDBManager.kTABLECATEGORY) (\(CJDBManager.kCATEGORYFIELDID) INTEGER PRIMARY KEY AUTOINCREMENT, \(CJDBManager.kCATEGORYFIELDNAME) TEXT);"
                    try? db.executeUpdate(stat, values: nil)
                    
                    // 创建“单品”表
                    stat = "CREATE TABLE \(CJDBManager.kTABLEPRODUCT) (\(CJDBManager.kPRODUCTFIELDID) INTEGER PRIMARY KEY AUTOINCREMENT, \(CJDBManager.kPRODUCTFIELDNAME) TEXT, \(CJDBManager.kPRODUCTFIELDPRICE) REAL, \(CJDBManager.kPRODUCTFIELDIMAGEPATH) TEXT);"
                    try? db.executeUpdate(stat, values: nil)
                })
            }
        }
        // 更新数据库版本号
        self.databaseQueue.inDatabase { (db) in
            try? db.executeUpdate("PRAGMA user_version = \(kCurrentVersion);", values: nil)
        }
    }
}
