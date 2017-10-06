//
//  ReplyCommentEntity.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/31.
//
//

import Foundation
import MySQL


// --评论Model
struct ReplyCommentEntity: QueryRowResultType, QueryParameterDictionaryType,Codable {
    
    let topic_id:Int
    let topic_title:String
    let comment_content:String
    let comment_id:Int
    let comment_time:Date
    
    
    static func decodeRow(r: QueryRowResult) throws -> ReplyCommentEntity {
        return try ReplyCommentEntity(
            topic_id: r <| 0,
            topic_title: r <| "topic_title",
            comment_content: r <| "comment_content",
            comment_id: r <| 3,
            comment_time: r <| "comment_time"
        )
    }
    func queryParameter() throws -> QueryDictionary {
        
        return QueryDictionary([
            "topic_id":topic_id
            ])
    }
}
