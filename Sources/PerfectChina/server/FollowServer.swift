//
//  FollowServer.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//


import PerfectLib
import MySQL

struct FollowServer {
    public static func follow(id1:Int,id2:Int)throws -> Bool{
 
        return try pool.execute{
            try $0.query("insert into follow (from_id,to_id) values(?,?) ON DUPLICATE KEY UPDATE create_time=CURRENT_TIMESTAMP ",[id1,id2])
            }.affectedRows > 0
    }
    
    public static func get_fans_of_user(user_id:Int,page_no:Int,page_size:Int) throws ->[UserEntity] {
    
        return try pool.execute{
            try $0.query("select u.* from follow f right join user u on f.from_id=u.id where f.to_id=? limit ?,?",[user_id,(page_no-1) * page_size,page_size])
        }
    }
    
    
    public static func get_follows_of_user(user_id:Int,page_no:Int,page_size:Int) throws ->[UserEntity] {
        
        return try pool.execute{
            try $0.query("select u.* from follow f right join user u on f.to_id=u.id where f.from_id=? limit ?,?",[user_id,(page_no-1) * page_size,page_size])
        }
    }
    
    public static func cancel_follow(id1:Int,id2:Int) throws -> Bool {
        
        return try pool.execute{
            try $0.query("delete from follow  where from_id=? and to_id=?",[id1,id2])
            }.affectedRows > 0
        
    }
    
    public static func get_follows_count(user_id:Int) throws -> [Count] {

        return try pool.execute{
            try $0.query("select count(f.id) as follows_count from follow f right join user u on f.to_id=u.id where from_id=?",[user_id])
        }
    }
    
    public static func get_fans_count(user_id:Int) throws -> [Count] {

        return try pool.execute{
            try $0.query("select count(f.id) as fans_count from follow  f right join user u on f.from_id=u.id where to_id=?",[user_id])
        }
    }
    
    public static func get_relation(id1:Int,id2:Int) throws -> [FollowEntity]{
 
        return try pool.execute{
            try $0.query("select * from follow where (from_id=? and to_id=?) or (from_id=? and to_id=?)",[id1,id2,id2,id1]);
        }
    }
    
}
