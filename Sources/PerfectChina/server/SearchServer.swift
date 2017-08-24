//
//  SearchServer.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//


import PerfectLib
import MySQL


struct SearchServer {
    
    public static func query_by_topic(query:String) throws -> [TopicEntity]{
        
        return try pool.execute{
            try $0.query("SELECT * FROM topic WHERE MATCH (title,content) AGAINST (? IN NATURAL LANGUAGE MODE);",[query])
        }
    }
    
    public static func query_by_user(query:String) throws -> [UserEntity]{
        
        return try pool.execute{
            try $0.query("SELECT * FROM user WHERE MATCH (username) AGAINST (? IN NATURAL LANGUAGE MODE);",[query])
        }
    }
    
    
    public static func quert_cout(query:String)throws -> Int {
        
        let row:[Count] = try pool.execute{
            try $0.query("SELECT COUNT(*) FROM topic WHERE MATCH (title,content) AGAINST (? IN NATURAL LANGUAGE MODE);",[query])
        }
        
        return row.count > 0 ? row[0].count : 0
    }
}
