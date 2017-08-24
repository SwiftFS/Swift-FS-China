//
//  comment.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//


import PerfectLib
import MySQL

struct CommentServer {
    
   public static func delete(user_id:Int,comment_id:Int)throws -> Bool{
        
        //        let status: QueryStatus = try pool.execute{ conn in
        //            try conn.query("delete from comment where id=? and user_id=?",[comment_id,user_id])
        //        }
        //
        //        if status.affectedRows > 0 {
        //            return true
        //        }else{
        //            return false
        //        }
        return try pool.execute{
            try $0.query("delete from comment where id=? and user_id=?",[comment_id,user_id])
            }.affectedRows > 0
    }
    
    
   public static func get_total_count_of_user(user_id:Int) throws -> Int{
        //        let row:[Count] = try pool.execute({ conn in
        //            try conn.query("select count(c.id) as count from comment c " +
        //                "right join topic t on c.topic_id=t.id " +
        //                " where c.user_id=? " ,[user_id])
        //        })
        //        if row.count > 0 {
        //            return row[0].count
        //        }else{
        //            return 0
        //        }
        let row:[Count] = try pool.execute{
            try $0.query("select count(c.id) as count from comment c " +
                "right join topic t on c.topic_id=t.id " +
                " where c.user_id=? " ,[user_id])
        }
        return row.count > 0 ? row[0].count : 0
    }
    
   public static func get_all_of_user(user_id:Int,page_no:Int,page_size:Int) throws -> [ReplyCommentEntity]{
        
        //        var page_no = page_no
        //        if page_no < 1 {
        //            page_no = 1
        //        }
        //        let row:[ReplyCommentEntity] = try pool.execute({ conn in
        //            try conn.query("select t.id as topic_id, t.title as topic_title, c.content as comment_content,c.id as comment_id, c.create_time as comment_time from comment c" +
        //                " right join topic t on c.topic_id=t.id" +
        //                " where c.user_id=? order by c.id desc limit ?,?",[user_id,(page_no - 1)*page_size,page_size])
        //        })
        //        return row
        
        var page_no = page_no
        if page_no < 1 {
            page_no = 1
        }
        return try pool.execute{
            try $0.query("select t.id as topic_id, t.title as topic_title, c.content as comment_content,c.id as comment_id, c.create_time as comment_time from comment c" +
                " right join topic t on c.topic_id=t.id" +
                " where c.user_id=? order by c.id desc limit ?,?",[user_id,(page_no - 1)*page_size,page_size])
        }
    }
    
   public static func query(comment_id:Int) throws -> CommentEntity? {
        //        let row:[CommentEntity] = try pool.execute({ conn in
        //            try conn.query("select c.*, u.avatar as avatar, u.username as user_name from comment c " +
        //                "left join user u on c.user_id=u.id " +
        //                "where c.id=? " ,[comment_id])
        //        })
        //        if row.count > 0 {
        //            return row[0]
        //        }else{
        //            return nil
        //        }
        let row:[CommentEntity] = try pool.execute{
            try $0.query("select c.*, u.avatar as avatar, u.username as user_name from comment c " +
                "left join user u on c.user_id=u.id " +
                "where c.id=? " ,[comment_id])
        }
        return row.count > 0 ? row[0] : nil
    }
    
   public static func get_last_reply_of_topic(topic_id:Int)throws ->NACommentEntity?{
        //        let row:[NACommentEntity] = try pool.execute({ conn in
        //            try conn.query("select c.*, u.username as user_name, u.id as user_id from comment c " +
        //                "left join user u on c.user_id=u.id " +
        //                "where c.topic_id=? order by c.id desc limit 1" ,[topic_id]);
        //        })
        //
        //        if row.count > 0 {
        //            return row[0]
        //        }else{
        //            return nil
        //        }
        let row:[NACommentEntity] = try pool.execute{
            try $0.query("select c.*, u.username as user_name, u.id as user_id from comment c " +
                "left join user u on c.user_id=u.id " +
                "where c.topic_id=? order by c.id desc limit 1" ,[topic_id])
        }
        return row.count > 0 ? row[0] : nil
    }
    
   public static func reset_topic_comment_num(topic_id:Int)throws -> Bool{
        // Updating
        //        let status: QueryStatus = try pool.execute{ conn in
        //            try conn.query("update topic set reply_num=(select count(id) from comment where topic_id=?) where id=?", [topic_id,topic_id])
        //        }
        //        if status.insertedID > 0 {
        //           return true  //更新成功
        //        }else{
        //           return false
        //        }
        
        return try pool.execute{
            try $0.query("update topic set reply_num=(select count(id) from comment where topic_id=?) where id=?", [topic_id,topic_id])
            }.insertedID > 0
    }
    
   public static func new(topic_id:Int,user_id:Int,content:String)throws -> UInt64?{
        
        //        let status: QueryStatus = try pool.execute{ conn in
        //            try conn.query("insert into comment(topic_id,user_id, content) values(?,?,?)",[topic_id,user_id,content])
        //        }
        //        if  status.insertedID > 0 {
        //            return status.insertedID
        //        }else{
        //            return nil
        //        }
        let status = try pool.execute{
            try $0.query("insert into comment(topic_id,user_id, content) values(?,?,?)",[topic_id,user_id,content])
        }
        return status.insertedID > 0 ? status.insertedID : nil
    }
    
   public static func get_total_count() throws -> [Count] {
        //        let row:[Count] = try pool.execute({ conn in
        //            try conn.query("select count(c.id) as comment_count from comment c ");
        //        })
        //        return row
        return try pool.execute{
            try $0.query("select count(c.id) as comment_count from comment c ")
        }
    }
    
   public static func get_total_count_of_topic(topic_id:Int?) throws -> Int {
        //logic error,how can topic_id == nil && topic_id == 0?
        //        if  topic_id == nil && topic_id == 0 {
        //            return 0
        //        }
        //        let row:[Count] = try pool.execute({ conn in
        //            try conn.query("select count(id) as count from comment where topic_id=?",[topic_id]);
        //
        //        })
        //        if row.count > 0 {
        //            return row[0].count
        //        }else{
        //            return 0
        //        }
        guard let t_id = topic_id,t_id != 0 else{ return 0 }
        let row:[Count] = try pool.execute{ try $0.query("select count(id) as count from comment where topic_id=?",[topic_id]) }
        return row.count > 0 ? row[0].count : 0
    }
    
   public static func get_all_of_topic(topic_id:Int,page_no:Int,page_size:Int) throws -> [CommentEntity]{
        //        var page_no = page_no
        //
        //        if topic_id == 0 {
        //            return []
        //        }
        //
        //        if page_no < 1 {
        //            page_no =  1
        //        }
        //
        //        let row:[CommentEntity] = try pool.execute({ conn in
        //            try conn.query("select c.*, u.avatar as avatar, u.username as user_name from comment c " +
        //                "left join user u on c.user_id=u.id " +
        //                "where c.topic_id=? order by c.id asc limit ?,?",[topic_id,(page_no - 1) * page_size,page_size]);
        //        })
        //        return row
        var page_no = page_no
        
        guard topic_id != 0 else {
            return []
        }
        
        if page_no < 1 {
            page_no =  1
        }
        
        return try pool.execute{
            try $0.query("select c.*, u.avatar as avatar, u.username as user_name from comment c " +
                "left join user u on c.user_id=u.id " +
                "where c.topic_id=? order by c.id asc limit ?,?",[topic_id,(page_no - 1) * page_size,page_size])
        }
    }
}
