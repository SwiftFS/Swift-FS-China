//
//  LikeServer.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//

import PerfectLib
import MySQL

struct LikeServer {
    
    public static func cancleLike(user_id:Int,topic_id:Int) throws -> Bool{
        
        return try pool.execute{
            try $0.query("delete from `like` where user_id = ? and topic_id = ?",[user_id,topic_id])
            }.affectedRows > 0
    }
    
    public static func like(user_id:Int,topic_id:Int) throws -> Bool{
   
        return try pool.execute{
            try $0.query("insert into `like` (user_id,topic_id) values(?,?) ON DUPLICATE KEY UPDATE create_time=CURRENT_TIMESTAMP",[user_id,topic_id])
            }.insertedID > 0
    }
    
    public static func is_like(current_userid:Int,topic_id:Int) throws -> Bool {

        let row:[Count] = try pool.execute{ conn in
            try conn.query("select count(l.id) as count from `like` l " +
                " where l.user_id=? and l.topic_id=?",[current_userid,topic_id])
        }
        return !(row.count > 0 && row[0].count < 1)
    }
}
