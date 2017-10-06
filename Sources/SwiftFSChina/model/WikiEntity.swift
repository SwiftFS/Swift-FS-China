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


struct WikiEntity: QueryRowResultType, QueryParameterDictionaryType,Codable {
    
    let id: Int
    let title: String
    let content: String
    let user_id: Int
    let create_time: Date
    let update_time: Date?
    let user_name: String
    let like_num: Int
    let reply_num: Int
    let view_num: Int
    let last_reply_id: Int
    let last_reply_name: String
    let last_reply_time: Date
    let is_recommend:Int
    let url_path:String
    
    
    enum Status: String, SQLEnumType {
        case created = "created"
        case verified = "verified"
    }
    
    
    // Decode query results (selecting rows) to a model
    static func decodeRow(r: QueryRowResult) throws -> WikiEntity {
        return try WikiEntity(
            id: r <| 0,
            title: r <| "title",
            content: r <| "content",
            user_id: r <| 3,
            create_time: r <| "create_time",
            update_time: r <|? "update_time",
            user_name: r <| "user_name",
            like_num: r <| 7,
            reply_num: r <| 9,
            view_num: r <| 11,
            last_reply_id: r <| 12,
            last_reply_name: r <| "last_reply_name",
            last_reply_time: r <| "last_reply_time",
            is_recommend: r <| "is_recommend",
            url_path: r <| "is_recommend"
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
