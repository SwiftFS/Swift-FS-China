//
//  WikiServer.swift
//  PerfectChina
//
//  Created by mubin on 2017/9/7.
//
//

import Foundation
import MySQL

struct WikiServer {
    
    //--新增文章
    public static func new(title:String,content:String,user_id:Int,user_name:String,is_recommend:Int,url_path:String)throws -> Int?{
        
        let status = try pool.execute{
            try $0.query("insert into wiki(title, content, user_id, user_name, category_id, create_time,url_path) values(?,?,?,?,?,?,?)"
                ,[title,content,user_id,user_name,is_recommend,Utils.now(),url_path])
        }
        return status.affectedRows > 0 ? Int(status.insertedID) : nil
    }
    
    
    public static func quert_recommends() throws -> [WikiEntity] {
        return try pool.execute{
            try $0.query("select id,title,content,user_id,create_time,update_time,user_name, " +
                "like_num,reply_num,view_num,last_reply_id,last_reply_name, " +
                "last_reply_time,is_recommend,url_path " +
                "from wiki where is_recommend = 1")
        }
    }
    
}
