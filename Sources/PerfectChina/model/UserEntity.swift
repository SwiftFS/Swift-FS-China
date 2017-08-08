//
//  UserModel.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/26.
//
//

import Foundation
import MySQL


extension UserEntity:HandyJSON {
    init() {
        self.init(id: AutoincrementID.noID, username: "", password: "", avatar: "", create_time: nil, city: "", website: "", company: "", sign: "", github: "", email: "", email_public: 0, is_admin: 0)
    }
}

struct UserID: IDType {
    let id: Int
    init(_ id: Int) {
        self.id = id
    }
}

struct UserEntity: QueryRowResultType, QueryParameterDictionaryType {
    let id: AutoincrementID<UserID>     //自增
    let username: String
    let password: String
    let avatar: String
    let create_time: Date?
    let city: String
    let website: String
    let company: String
    let sign: String
    let github: String
    let email: String
    let email_public: Int
    let is_admin: Int
    
    enum Status: String, SQLEnumType {
        case created = "created"
        case verified = "verified"
    }
    
    // Decode query results (selecting rows) to a model
    static func decodeRow(r: QueryRowResult) throws -> UserEntity {
        return try UserEntity(
         id: r <| 0,
         username: r <| "username",
         password: r <| "password",
         avatar: r <| "avatar",
         create_time: r <|? "create_time",
         city: r <| "city",
         website: r <| "website",
         company: r <| "company",
         sign: r <| "sign",
         github: r <| "github",
         email: r <| "email",
         email_public: r <| 11,
         is_admin: r <| 12
        )
    }
    
    // Use this model as a query paramter
    // See inserting example
    func queryParameter() throws -> QueryDictionary {
        
        return QueryDictionary([
            "username": username,
            "password": password,
            "avatar":avatar
        ])
    }
}
