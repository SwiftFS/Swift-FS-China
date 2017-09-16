//
//  Count.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//

import Foundation
import MySQL

//用于展示个数

struct IDEntity: QueryRowResultType, QueryParameterDictionaryType {
    
    let id: Int
    
    static func decodeRow(r: QueryRowResult) throws -> IDEntity {
        return try IDEntity(
            id: r <| 0
        )
    }
    func queryParameter() throws -> QueryDictionary {
        
        return QueryDictionary([
            "id":id
            ])
    }
}
