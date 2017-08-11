//
//  AuthServer.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/26.
//
//

import PerfectLib
import MySQL

struct UserServer {
    
    public static func update_avatar(avatar:String,userid:Int) throws -> Bool{
        //        let status: QueryStatus = try pool.execute{ conn in
        //            try conn.query(" update user set avatar=? where id=?", [avatar,userid])
        //        }
        //        if status.affectedRows > 0 {
        //            return true
        //        }else{
        //            return false
        //        }
        return try pool.execute{
            try $0.query(" update user set avatar=? where id=?", [avatar,userid])
            }.affectedRows > 0
    }
    
    public static func update_pwd(userid:Int,new_pwd:String)throws->Bool{
        //        let status: QueryStatus = try pool.execute{ conn in
        //            try conn.query(" update user set password=? where id=?", [new_pwd,userid])
        //        }
        //
        //        if status.affectedRows > 0 {
        //            return true
        //        }else{
        //            return false
        //        }
        return try pool.execute{
            try $0.query(" update user set password=? where id=?", [new_pwd,userid])
            }.affectedRows > 0
    }
    
    public static func update(user_id:Int,email:String,email_public:Int,city:String,company:String,github:String,website:String,sign:String) throws -> Bool{
        //        let status: QueryStatus = try pool.execute{ conn in
        //            try conn.query("update user set email=?, email_public=?, city=?, company=?, github=?, website=?, sign=? where id=?", [email,email_public,city,company,github,website,sign,user_id])
        //        }
        //
        //        if status.affectedRows > 0 {
        //            return true
        //        }else{
        //            return false
        //        }
        return try pool.execute{
            try $0.query("update user set email=?, email_public=?, city=?, company=?, github=?, website=?, sign=? where id=?", [email,email_public,city,company,github,website,sign,user_id])
            }.affectedRows > 0
    }
    
    public static func query_ids(username:String) throws -> [IDEntity]?{
        //        let row:[IDEntity] = try pool.execute({ conn in
        //            try conn.query("select id from user where username in ("+" \(username) " + "+");
        //        })
        //        if row.count > 0 {
        //            return row
        //        }else{
        //            return nil
        //        }
        let row:[IDEntity] = try pool.execute{
            try $0.query("select id from user where username in ("+" \(username) " + "+");
        }
        return row.count > 0 ? row : nil
    }
    
    public static func query(username:String,password:String) throws -> [UserEntity] {
        //        let row:[UserEntity] = try pool.execute({ conn in
        //            try conn.query("select * from user where username=? and password=?",[username,password]);
        //        })
        //        return row
        return try pool.execute{ conn in
            try conn.query("select * from user where username=? and password=?",[username,password]);
        }
    }
    
    //是否登录
    public static func query_by_username(username:String) throws -> Bool  {
        
        //        let row:[UserEntity] = try pool.execute({ conn in
        //            try conn.query("select * from user where username=? limit 1",[username]);
        //        })
        //
        //        if row.count == 0 {
        //            return false
        //        }else{
        //            return true
        //        }
        let row:[UserEntity] = try pool.execute{
            try $0.query("select * from user where username=? limit 1",[username]);
        }
        return row.count != 0
    }
    
    
    public static func new(username:String,password:String,avatar:String) throws -> Bool{
        //        let user = UserEntity.init(id: .noID, username: username, password: password, avatar: avatar, create_time: nil, city: "", website: "", company: "", sign: "", github: "", email: "", email_public: 0, is_admin: 0)
        //
        //        let status: QueryStatus = try pool.execute{ conn in
        //              try conn.query("INSERT INTO user SET ?",[user])
        //        }
        //        if status.insertedID > 0 {
        //            return true
        //        }else{
        //            return false
        //        }
        
        let user = UserEntity(id: .noID, username: username, password: password, avatar: avatar, create_time: nil, city: "", website: "", company: "", sign: "", github: "", email: "", email_public: 0, is_admin: 0)
        return try pool.execute{
            try $0.query("INSERT INTO user SET ?",[user])
            }.insertedID > 0
    }
    
    public static func get_total_count() throws -> [Count] {
        //        let row:[Count] = try pool.execute({ conn in
        //            try conn.query("select count(*) from user");
        //        })
        //        return row
        return try pool.execute{
            try $0.query("select count(*) from user");
        }
    }
    
    public static func query_by_username(username:String) throws -> UserEntity?{
        //        let row:[UserEntity] = try pool.execute({ conn in
        //            try conn.query("select * from user where username=? limit 1",[username]);
        //        })
        //        if  row.count > 0{
        //            return row[0]
        //        }else{
        //            return nil
        //        }
        let row:[UserEntity] = try pool.execute{
            try $0.query("select * from user where username=? limit 1",[username])
        }
        return row.count > 0 ? row[0] : nil
    }
    
    public static func query_by_id(id:Int) throws -> UserEntity?{
        //        let row:[UserEntity] = try pool.execute({ conn in
        //            try conn.query("select * from user where id=?",[id]);
        //        })
        //        if  row.count > 0{
        //            return row[0]
        //        }else{
        //            return nil
        //        }
        let row:[UserEntity] = try pool.execute{
            try $0.query("select * from user where id=?",[id])
        }
        return row.count > 0 ? row[0] : nil
    }
}
