//
//  NotificationServer.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//


import PerfectLib
import MySQL

struct NotificationServer {
    
    public static func get_all(user_id:Int,n_type:String,page_no:String,page_size:Int) throws -> [NotificationEntity]{
        var page_no = page_no.int ?? 0
        var row:[NotificationEntity]?
        if page_no < 1 {
            page_no = 1
        }
        
        if n_type == "all" {
            row = try pool.execute({ conn in
                try conn.query("select n.*, u.username as from_username, u.avatar as avatar,u.username as username, t.title as topic_title, c.id as comment_id, c.content as comment_content  " +
                    " from notification n " +
                    "left join user u on n.from_id=u.id " +
                    "left join topic t on n.topic_id=t.id" +
                    " left join comment c on n.comment_id=c.id " +
                    " where n.user_id = ?" +
                    " order by id desc limit ?,?",[user_id,(page_no-1)*page_size,page_size]
                )
            })
        }else if n_type == "unread"{
            
            row = try pool.execute({ conn in
                try conn.query("select count(n.id) as count " +
                    "from notification n" +
                    "left join user u on n.from_id=u.id" +
                    "left join topic t on n.topic_id=t.id" +
                    "left join comment c on n.comment_id=c.id " +
                    "where n.user_id =? and n.status=0",[user_id]
                );
            })
        }
        if  row != nil && row!.count > 0 {
            return row!
        }else{
            return []
        }
        
        //        let row:[NotificationEntity] = try pool.execute{
        //            if n_type == "all" {
        //                return try $0.query("select count(n.id) as count " +
        //                    "from notification n" +
        //                    "left join user u on n.from_id=u.id" +
        //                    "left join topic t on n.topic_id=t.id" +
        //                    "left join comment c on n.comment_id=c.id " +
        //                    "where n.user_id =? and n.status=0",[user_id]
        //                )
        //            }
        //            else if n_type == "unread"{
        //                return try $0.query("select count(n.id) as count " +
        //                    "from notification n" +
        //                    "left join user u on n.from_id=u.id" +
        //                    "left join topic t on n.topic_id=t.id" +
        //                    "left join comment c on n.comment_id=c.id " +
        //                    "where n.user_id =? and n.status=0",[user_id]
        //                )
        //            }
        //            return []
        //        }
        //        return row
    }
    
    
    public static func get_total_count(user_id:Int,n_type:String) throws -> Int {
        var row:[Count]?
        
        if n_type == "all" {
            row = try pool.execute({ conn in
                try conn.query("select count(n.id) as count " +
                    "from notification n" +
                    "left join user u on n.from_id=u.id" +
                    "left join topic t on n.topic_id=t.id" +
                    "left join comment c on n.comment_id=c.id " +
                    "where n.user_id =?",[user_id]
                );
            })
        }else if n_type == "unread"{
            
            row = try pool.execute({ conn in
                try conn.query("select count(n.id) as count " +
                    "from notification n" +
                    "left join user u on n.from_id=u.id" +
                    "left join topic t on n.topic_id=t.id" +
                    "left join comment c on n.comment_id=c.id " +
                    "where n.user_id =? and n.status=0",[user_id]
                );
            })
        }
        if (row != nil) && row!.count > 0 {
            return 0
        }else{
            return row![0].count
        }
    }
    
    // 评论了某个人的文章
    public static func comment_notify(from_id:Int,content:String,topic_id:Int,comment_id:Int) throws{
        let _:[Count] = try pool.execute({ conn in
            try conn.query("select user_id from topic where id=?",[topic_id]);
        })
        let user_id = 0
        let _:[Count] = try pool.execute({ conn in
            try conn.query("insert into notification(user_id, from_id, type, content, topic_id, comment_id) values(?,?,?,?,?,?)",[user_id,topic_id,0,content,topic_id,comment_id]);
        })
        //        _ = try pool.execute{
        //            try $0.query("select user_id from topic where id=?",[topic_id])
        //            try $0.query("insert into notification(user_id, from_id, type, content, topic_id, comment_id) values(?,?,?,?,?,?)",[0,topic_id,0,content,topic_id,comment_id])
        //        }
    }
    
    // 评论文章的时候提及了某个人
    public static func comment_mention(user_id:Int,from_id:Int,content:String,topic_id:Int,comment_id:Int) throws{
        //        let _:[Count] = try pool.execute({ conn in
        //            try conn.query("insert into notification(user_id, from_id, type, content, topic_id, comment_id) values(?,?,?,?,?,?)",[user_id,
        //            from_id,1,content,topic_id,comment_id])
        //        })
        _ = try pool.execute{
            try $0.query("insert into notification(user_id, from_id, type, content, topic_id, comment_id) values(?,?,?,?,?,?)",[user_id,
                                                                                                                                from_id,1,content,topic_id,comment_id])
        }
    }
    
    //关注了某人
    public static func follow_notify(from_id:Int,user_id:Int) throws{
        //        let _:[Count] = try pool.execute({ conn in
        //            try conn.query("insert into notification(user_id, from_id, type, content) values(?,?,?,?)",[user_id,from_id,2,""]);
        //        })
        _ = try pool.execute{
            try $0.query("insert into notification(user_id, from_id, type, content) values(?,?,?,?)",[user_id,from_id,2,""])
        }
    }
    //全部标记为已读
    public static func update_status(user_id:Int) throws -> Bool{
        //        let _:[Count] = try pool.execute({ conn in
        //            try conn.query("update notification set status = ? where user_id=?",[1,user_id]);
        //        })
        return try pool.execute{
            try $0.query("update notification set status = ? where user_id=?",[1,user_id])
        }.affectedRows > 0
    }
    //删除所有通知
    public static func delete_all(user_id:Int) throws -> Bool {
        //        var user_id = row[0].user_id
        //        let _:[Count] = try pool.execute({ conn in
        //            try conn.query("delete from notification where user_id=?",[user_id]);
        //        })
        return try pool.execute{
            try $0.query("delete from notification where user_id=?",[user_id])
        }.affectedRows > 0
    }
    //删除某条通知
    public static func delete(id:Int,user_id:Int) throws -> Bool {
        //        let _:[Count] = try pool.execute({ conn in
        //            try conn.query("delete from notification where id=? and user_id=?",[id,user_id]);
        //        })
        return try pool.execute{
            try $0.query("delete from notification where id=? and user_id=?",[id,user_id])
        }.affectedRows > 0
    }
    
    
    
    
}
