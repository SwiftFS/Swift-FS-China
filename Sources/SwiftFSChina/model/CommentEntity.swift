//
//  CommentEntity.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/31.
//
//

import Foundation
import MySQL


extension CommentEntity:HandyJSON{
    init() {
        self.init(id: 0, topic_id: 0, user_id: 0, create_time: Date(), content: "", avatar: nil, user_name: "")
    }
}

// --评论Model
struct CommentEntity: QueryRowResultType, QueryParameterDictionaryType {
    
    let id: Int
    let topic_id:Int
    let user_id:Int
    let create_time:Date
    let content:String
    let avatar:String?      //optional
    let user_name:String
    
    enum Status: String, SQLEnumType {
        case created = "created"
        case verified = "verified"
    }
    
    static func decodeRow(r: QueryRowResult) throws -> CommentEntity {
        return try CommentEntity(
            id: r <| 0,
            topic_id: r <| 1,
            user_id: r <| 2,
            create_time: r <| "create_time",
            content: r <| 4,
            avatar: r <|? "avatar",
            user_name: r <| "user_name"
        )
    }
    func queryParameter() throws -> QueryDictionary {
        
        return QueryDictionary([
            "id":id,
            "topic_id":topic_id,
            "user_id":user_id,
            "create_time":create_time,
            "content":content,
            "avatar":avatar,
            "user_name":user_name
            ])
    }
}
