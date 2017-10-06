//
//  Config.swift
//  Perfect-App-Template
//
//  Created by Jonathan Guthrie on 2017-02-20.
//	Copyright (C) 2017 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import Foundation
import MySQL
import CMySQL
import PerfectCURL
import PerfectSMTP
import PerfectRedis


public var pool: ConnectionPool!

var pwd_secret:String!


struct Options:ConnectionOption {
    var database: String
    
    var password: String
    
    var user: String
    
    var port: Int
    
    var host: String
    
    var encoding: Connection.Encoding
}

func connectionDatabase() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current //设置时区，时间为当前系统时间
        //输出样式
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
    
//应用启动设置
        let dic = ApplicationConfiguration()
        let host = dic.mysqlhost
        let user = dic.mysqluser
        let pwd = dic.mysqlpwd
        let database = dic.mysqldbname
        let port = dic.mysqlport
    
        pwd_secret = dic.pwd_secret
    
        let option = Options.init(database: database, password: pwd, user: user, port: port, host: host, encoding: Connection.Encoding.UTF8MB4)
    
        pool = ConnectionPool.init(options: option)
        pool.maxConnections = 10

    
        do{
            let _:[Check] = try pool.execute({ conn in
                try conn.query("show tables");
            })
           Log.info(message: "连接数据库成功")
            
        }catch{
            fatalError("\(error)") // fatal error launching one of the servers
        }

    }
    
    struct Check: QueryRowResultType, QueryParameterDictionaryType {
    let Tables_in_blog: String
    
    enum Status: String, SQLEnumType {
    case created = "created"
    case verified = "verified"
    }
    
    // Decode query results (selecting rows) to a model
    static func decodeRow(r: QueryRowResult) throws -> Check {
    return try Check(
    Tables_in_blog: r <| "Tables_in_blog" // as field name
    )
    }
    
    // Use this model as a query paramter
    // See inserting example
    func queryParameter() throws -> QueryDictionary {
    return QueryDictionary([
    //"id": // auto increment
    "Tables_in_blog": Tables_in_blog,
    ])
    }
}




