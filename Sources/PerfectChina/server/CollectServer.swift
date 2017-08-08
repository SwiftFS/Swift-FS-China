//
//  CollectServer.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//


import PerfectLib
import MySQL


class CollectServer {
    
  
    class func cancel_collect(user_id:Int,topic_id:Int) throws -> Bool {
        let status: QueryStatus = try pool.execute{ conn in
            try conn.query("delete from collect where user_id=? and topic_id=?",[user_id,topic_id])
        }
        
        if status.affectedRows > 0 {
            return true
        }else{
            return false
        }
        
    }
    
    class func collect(user_id:Int,topic_id:Int) throws -> Bool {
        let status: QueryStatus = try pool.execute{ conn in
            try conn.query("insert into collect (user_id,topic_id) values(?,?) ON DUPLICATE KEY UPDATE create_time=CURRENT_TIMESTAMP ",[user_id,topic_id])
        }
        if status.insertedID > 0 {
            return true
        }else{
            return false
        }
    }
    
    class func get_all_of_user(user_id:Int,page_no:Int,page_size:Int) throws -> [CollectEntity] {
        
        let row:[CollectEntity] = try pool.execute({ conn in
            try conn.query("select t.*, u.avatar as avatar, cc.name as category_name from collect c " +
                " right join topic t on c.topic_id=t.id " +
                " left join user u on t.user_id=u.id " +
                " left join category cc on t.category_id=cc.id " +
                " where c.user_id=? order by c.id desc limit ?,? "
                ,[user_id,(page_no - 1) * page_size,page_size]);
        })
        
        return row
    }

    
    class func is_collect(current_userid:Int,topic_id:String) throws -> Bool {
        let row:[Count] = try pool.execute({ conn in
            try conn.query("select count(c.id) as count from collect c " +
                            " where c.user_id=? and c.topic_id=?",[current_userid,topic_id]);
        })
        
        if row.count > 0 && row[0].count < 1 {
            return false
        }else{
            return true
        }
    }
}
