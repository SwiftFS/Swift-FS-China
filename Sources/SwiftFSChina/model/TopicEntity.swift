//
//  TopicEntity.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/29.
//
//

import Foundation
import MySQL
import PerfectLib



struct TopicEntity: QueryRowResultType, QueryParameterDictionaryType,Codable {
    
    let id: Int
    let title: String
    let content: String
    let user_id: Int
    let create_time: Date
    let update_time: Date?
    let user_name: String
    let like_num: Int
    let collect_num: Int
    let reply_num: Int
    let follow: Int
    let view_num: Int
    let last_reply_id: Int
    let last_reply_name: String
    let last_reply_time: Date
    let catagory_id: Int
    let is_good: Int
    
    
    
    
    
    enum Status: String, SQLEnumType {
        case created = "created"
        case verified = "verified"
    }
    
    
    // Decode query results (selecting rows) to a model
    static func decodeRow(r: QueryRowResult) throws -> TopicEntity {
        return try TopicEntity(
            id: r <| 0,
            title: r <| "title",
            content: r <| "content",
            user_id: r <| 3,
            create_time: r <| "create_time",
            update_time: r <|? "update_time",
            user_name: r <| "user_name",
            like_num: r <| 7,
            collect_num: r <| 8,
            reply_num: r <| 9,
            follow: r <| 10,
            view_num: r <| 11,
            last_reply_id: r <| 12,
            last_reply_name: r <| "last_reply_name",
            last_reply_time: r <| "last_reply_time",
            catagory_id: r <| 15,
            is_good: r <| 16
        )
    }
    
    // Use this model as a query paramter
    // See inserting example
    func queryParameter() throws -> QueryDictionary {
        
        return QueryDictionary([
            "id":id
            ])
    }
}
