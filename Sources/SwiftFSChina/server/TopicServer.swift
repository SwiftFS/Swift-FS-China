//
//  Topic.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//

import PerfectLib
import MySQL
import Foundation

struct TopicServer {
    
    public static func new(title:String,content:String,user_id:Int,user_name:String,category_id:Int)throws -> Int?{

        let status = try pool.execute{
            try $0.query("insert into topic(title, content, user_id, user_name, category_id, create_time) values(?,?,?,?,?,?)"
                ,[title,content,user_id,user_name,category_id,Utils.now()])
        }
        return status.affectedRows > 0 ? Int(status.insertedID) : nil
    }
    
    public static func update(topic_id:Int,title:String,content:String,user_id:Int,category_id:Int) throws -> Bool {

        return try pool.execute{
            try $0.query("update topic set title=?, content=?, category_id=?, update_time=? where id=? and user_id=?"
                ,[title,content,category_id,Utils.now(),topic_id,user_id])
            }.affectedRows > 0
    }
    
    
    public static func get_my_topic(user_id:Int,id:Int) throws -> [ArticleEntity] {
  
        return try pool.execute{
            try $0.query("select t.*, u.avatar as avatar, c.name as category_name from topic t " +
                " left join user u on t.user_id=u.id " +
                " left join category c on t.category_id=c.id " +
                " where t.id=? and user_id=?"
                ,[id,user_id]
            )
        }
    }
    
    public static func delete_topic(user_id:Int,topic_id:Int) throws -> Bool {
 
        return try pool.execute{
            try $0.query("delete from topic where id=? and user_id=?",[topic_id,user_id])
            }.affectedRows > 0
    }
    
    public static func get_all_of_user(user_id:Int,page_no:Int,page_size:Int) throws -> [ArticleEntity] {
       
        var page_no = page_no
        if page_no < 1 {
            page_no = 1
        }
        return try pool.execute{
            try $0.query("select t.*, u.avatar as avatar, c.name as category_name  from topic t " +
                "left join user u on t.user_id=u.id " +
                "left join category c on t.category_id=c.id " +
                " where t.user_id=? order by t.id desc limit ?,?"
                ,[user_id,(page_no - 1) * page_size,page_size]
            )
        }
    }
    
    public static func get_all_hot_of_user(user_id:Int,page_no:Int,page_size:Int) throws -> [ArticleEntity] {
        var page_no = page_no
        if page_no < 1 {
            page_no = 1
        }
    
        return try pool.execute{
            try $0.query("select t.*, u.avatar as avatar, c.name as category_name  from topic t " +
                "left join user u on t.user_id=u.id " +
                "left join category c on t.category_id=c.id " +
                "where t.user_id=? order by t.reply_num desc, like_num desc limit ?,?"
                ,[user_id,(page_no - 1) * page_size,page_size]
            )
        }
    }
    
    public static func get_total_hot_count_of_user(user_id:Int) throws -> Int {
      
        let row:[Count] = try pool.execute{
            try $0.query("select count(id) as count from topic where user_id=?",[user_id])
        }
        return row.count > 0 ? row[0].count : 0
    }
    
    public static func get_total_count() throws -> [Count] {
 
        return try pool.execute{
            try $0.query("select count(*) from topic")
        }
    }
    
    public static func get_total_count_of_user(user_id:Int) throws -> Int {
   
        let row:[Count] = try pool.execute{
            try $0.query("select count(id) as c from topic where user_id=?",[user_id]);
        }
        return row.count > 0 ? row[0].count : 0
    }
    
    public static func get(id:Int) throws -> [ArticleEntity]{

        return try pool.execute{
            //          ("update topic set view_num=view_num+1 where id=?", {tonumber(id)})
            try $0.query("select t.*, u.avatar as avatar, c.name as category_name from topic t " +
                "left join user u on t.user_id=u.id " +
                "left join category c on t.category_id=c.id " +
                "where t.id=?",[id])
        }
    }
    
    public static func get_all(topic_type:String,category:String,page_no:Int,page_size:Int) -> [ArticleEntity]?{
        
        var page_no = page_no
        let page_size = page_size
        let category = category.int!
        if page_no < 1 {
            page_no = 1
        }
        var row:[ArticleEntity]?
        do{
            if category != 0  {
                if topic_type == "default" {
                    row = try pool.execute({ conn in
                        try conn.query("select t.*, c.name as category_name, u.avatar as avatar from topic t " +
                            "left join user u on t.user_id=u.id " +
                            "left join category c on t.category_id=c.id " +
                            "where t.category_id=? " +
                            "order by t.id desc limit ?,? ",
                                       [category,(page_no - 1)*page_size,page_size]
                        )
                    })
                }else if topic_type == "recent-reply"{
                    row = try pool.execute({ conn in
                        try conn.query("select t.*, c.name as category_name, u.avatar as avatar from topic t " +
                            "left join user u on t.user_id=u.id " +
                            "left join category c on t.category_id=c.id " +
                            "where t.category_id=? " +
                            "order by t.last_reply_time desc limit ?,?",
                                       [category,(page_no - 1)*page_size,page_size]
                        )
                    })
                }else if topic_type == "good"{
                    row = try pool.execute({ conn in
                        try conn.query("select t.*, c.name as category_name, u.avatar as avatar from topic t " +
                            "left join user u on t.user_id=u.id " +
                            "left join category c on t.category_id=c.id " +
                            "where t.is_good=1 and t.category_id=? " +
                            "order by t.id desc limit ?,?",
                                       [category,(page_no - 1)*page_size,page_size]
                        )
                    })
                }else if topic_type == "noreply" {
                    row = try pool.execute({ conn in
                        try conn.query("select t.*, c.name as category_name, u.avatar as avatar from topic t " +
                            "left join user u on t.user_id=u.id " +
                            "left join category c on t.category_id=c.id " +
                            "where t.reply_num=0 and t.category_id=? " +
                            "order by t.id desc limit ?,?",
                                       [category,(page_no - 1)*page_size,page_size]
                        )
                    })
                }
            }else{
                if topic_type == "default" {
                    row = try pool.execute({ conn in
                        try conn.query("select t.*, c.name as category_name, u.avatar as avatar from topic t " +
                            "left join user u on t.user_id=u.id " +
                            "left join category c on t.category_id=c.id  " +
                            "order by t.id desc limit ?,?",
                                       [(page_no - 1)*page_size,page_size]
                        )
                    })
                }else if topic_type == "recent-reply" {
                    row = try pool.execute({ conn in
                        try conn.query("select t.*, c.name as category_name, u.avatar as avatar from topic t " +
                            "left join user u on t.user_id=u.id " +
                            "left join category c on t.category_id=c.id " +
                            "order by t.last_reply_time desc limit ?,?",
                                       [(page_no - 1)*page_size,page_size]
                        )
                    })
                }else if topic_type == "good" {
                    row = try pool.execute({ conn in
                        try conn.query("select t.*, c.name as category_name, u.avatar as avatar from topic t " +
                            "left join user u on t.user_id=u.id " +
                            "left join category c on t.category_id=c.id " +
                            "where t.is_good=1 " +
                            "order by t.id desc limit ?,? ",
                                       [(page_no - 1)*page_size,page_size]
                        )
                    })
                }else if topic_type == "noreply"{
                    row = try pool.execute({ conn in
                        try conn.query("select t.*, c.name as category_name, u.avatar as avatar from topic t " +
                            "left join user u on t.user_id=u.id " +
                            "left join category c on t.category_id=c.id " +
                            "where t.reply_num=0 " +
                            "order by t.id desc limit ?,?",
                                       [(page_no - 1)*page_size,page_size]
                        )
                    })
                }
            }
        }catch{
            Log.error(message: "\(error)")
            return nil
        }
        return row
    }
    
    public static func get_total_count(topic_type:String?,category:String?) throws -> Int {
        let categoryNum = category?.int
        do{
            let row:[Count] = try pool.execute{
                if let type = topic_type{
                    switch type {
                    case "recent-reply":
                        return try $0.query("select count(id) as c from topic" + (categoryNum != 0 ? "where category_id=?" : ""),[category])
                    case "good":
                        return try $0.query("select count(id) as c from topic where is_good=1" + (categoryNum != 0 ? "and category_id=?" : ""),[category])
                    case "noreply":
                        return try $0.query("select count(id) as c from topic where reply_num=0" + (categoryNum != 0 ? "and category_id=?" : ""),[category])
                    default:
                        return try $0.query("select count(id) as c from topic" + (categoryNum != 0 ? "where category_id=?" : ""),[category])
                    }
                }
                else{
                    return try $0.query("select count(id) as c from topic" + (categoryNum != 0 ? "where category_id=?" : ""),[category])
                }
            }
            return row[0].count
            
          
        }catch{
            return 0
        }
    }
    public static func reset_last_reply(topic_id:Int,user_id:Int,user_name:String,last_reply_time:Date) throws{
        
 
        _ = try pool.execute{
            try $0.query("update topic set last_reply_id=?, last_reply_name=?, last_reply_time=? where id=?", [user_id,user_name,last_reply_time,topic_id])
        }
    }
}
