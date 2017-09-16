//
//  NotificationEntity.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/30.
//
//

import Foundation
import MySQL


extension NotificationEntity:HandyJSON {
    init() {
        self.init(id: 0, user_id: 0, type: 0, from_id: 0, content: "", topic_id: 0, comment_id: 0, status: 0, create_time: Date.init(), from_username: "", avatar: "", username: "", topic_title: "", comment_content: "")
    }
}

//用于展示个数
struct NotificationEntity: QueryRowResultType, QueryParameterDictionaryType {
    
    let id: Int
    let user_id: Int
    let type: Int
    let from_id: Int
    let content:String
    let topic_id:Int
    let comment_id:Int
    let status:Int
    let create_time:Date
    let from_username:String
    let avatar:String
    let username:String
    let topic_title:String
    let comment_content:String
    
    
    static func decodeRow(r: QueryRowResult) throws -> NotificationEntity {
        return try NotificationEntity(
            id: r <| 0,
            user_id: r <| 1,
            type: r <| 2,
            from_id: r <| 3,
            content: r <| "content",
            topic_id: r <| 5,
            comment_id: r <| 6,
            status: r <| 7,
            create_time: r <| "create_time",
            from_username: r <| "from_username",
            avatar: r <| "avatar",
            username: r <| "username",
            topic_title: r <| "topic_title",
            comment_content: r <| "comment_content"
        )
    }
    
    func queryParameter() throws -> QueryDictionary {
        
        return QueryDictionary([
            "id":id
            ])
    }
}

