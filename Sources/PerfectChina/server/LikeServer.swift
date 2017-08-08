//
//  LikeServer.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//

import PerfectLib
import MySQL

class LikeServer {
    
    class func like(user_id:Int,topic_id:Int) throws -> Bool{
        let status: QueryStatus = try pool.execute{ conn in
            try conn.query("insert into `like` (user_id,topic_id) values(?,?) ON DUPLICATE KEY UPDATE create_time=CURRENT_TIMESTAMP",[user_id,topic_id])
        }
        if status.insertedID > 0 {
            return true
        }else{
            return true
        }

    }
    
    class func is_like(current_userid:Int,topic_id:Int) throws -> Bool {
        
        let row:[Count] = try pool.execute({ conn in
            try conn.query("select count(l.id) as count from `like` l " +
                " where l.user_id=? and l.topic_id=?",[current_userid,topic_id]);
        })
        
        if row.count > 0 && row[0].count < 1 {
            return false
        }else{
            return true
        }
    }
}
