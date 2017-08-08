//
//  FollowEntity.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//

import Foundation
import MySQL


struct FollowEntity: QueryRowResultType, QueryParameterDictionaryType {
    
    let id: Int
    let from_id:Int
    let to_id:Int
    let create_time:Date
    
    static func decodeRow(r: QueryRowResult) throws -> FollowEntity {
        return try FollowEntity(
            id: r <| 0,
            from_id: r <| 1,
            to_id: r <| 2,
            create_time: r <| "create_time"
        )
    }
    func queryParameter() throws -> QueryDictionary {
        
        return QueryDictionary([
            "id":id
            ])
    }
}
