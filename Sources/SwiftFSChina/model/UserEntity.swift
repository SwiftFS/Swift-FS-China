//
//  UserModel.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/26.
//
//

import Foundation
import MySQL


struct UserID: IDType {
    let id: Int
    init(_ id: Int) {
        self.id = id
    }
}

struct UserEntity: QueryRowResultType, QueryParameterDictionaryType,Codable{
    let id: Int
    let username: String
    let password: String
    let avatar: String
    let create_time: Date?
    let city: String
    let website: String
    let company: String
    let sign: String
    let github: String
    let github_name: String
    let is_verify:Int
    let github_id: Int?
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
         github_name: r <| "github_name",
         is_verify: r <| 11,
         github_id: r <|? 12,
         email: r <| "email",
         email_public: r <| 14,
         is_admin: r <| 15
        )
    }
    
    // Use this model as a query paramter
    // See inserting example
    func queryParameter() throws -> QueryDictionary {
        
        return QueryDictionary([
            "username": username,
            "password": password,
            "avatar":avatar,
            "email":email,
            "github_id":github_id,
            "github_name":github_name
        ])
    }
}
