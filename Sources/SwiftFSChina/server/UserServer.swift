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
    
    //是否管理员
    public static func check_is_admin(userid:Int) throws -> Int{
        let row:[IDEntity] = try pool.execute{
            try $0.query("select is_admin from user where userid = ?",[userid]);
        }
        return row.count
    }
    
    public static func update_avatar(avatar:String,userid:Int) throws -> Bool{

        return try pool.execute{
            try $0.query(" update user set avatar=? where id=?", [avatar,userid])
            }.affectedRows > 0
    }
    
    public static func update_pwd(userid:Int,new_pwd:String)throws->Bool{

        return try pool.execute{
            try $0.query(" update user set password=? where id=?", [new_pwd,userid])
            }.affectedRows > 0
    }
    
    public static func update(user_id:Int,email:String,email_public:Int,city:String,company:String,github:String,website:String,sign:String) throws -> Bool{
      
        return try pool.execute{
            try $0.query("update user set email=?, email_public=?, city=?, company=?, github=?, website=?, sign=? where id=?", [email,email_public,city,company,github,website,sign,user_id])
            }.affectedRows > 0
    }
    
    public static func query_ids(username:String) throws -> [IDEntity]?{
  
        let row:[IDEntity] = try pool.execute{
            try $0.query("select id from user where username in ("+" \(username) " + "+");
        }
        return row.count > 0 ? row : nil
    }
    
    public static func query(username:String,password:String) throws -> [UserEntity] {
 
        return try pool.execute{ conn in
            try conn.query("select * from user where username=? and password=?",[username,password]);
        }
    }
    
    //是否登录
    public static func query_by_username(username:String) throws -> Bool  {

        let row:[UserEntity] = try pool.execute{
            try $0.query("select * from user where username=? limit 1",[username]);
        }
        return row.count != 0
    }
    
    
    public static func new(username:String,password:String,avatar:String,email:String,github_id:Int,github_name:String) throws -> Int?{
        
       let user = UserEntity(id: .noID, username: username, password: password, avatar: avatar, create_time: nil, city: "", website: "", company: "", sign: "", github: "", github_name: github_name, is_verify: 0, github_id: github_id, email: email, email_public: 0, is_admin: 0)
        let status = try pool.execute{
            try $0.query("INSERT INTO user SET ?",[user])
        }
        return status.insertedID > 0 ? Int(status.insertedID) : nil
    }
    
    public static func get_total_count() throws -> [Count] {
 
        return try pool.execute{
            try $0.query("select count(*) from user");
        }
    }
    
    public static func query_by_username(username:String) throws -> UserEntity?{

        let row:[UserEntity] = try pool.execute{
            try $0.query("select * from user where username=? limit 1",[username])
        }
        return row.count > 0 ? row[0] : nil
    }
    
    public static func query_by_id(id:Int) throws -> UserEntity?{
 
        let row:[UserEntity] = try pool.execute{
            try $0.query("select * from user where id=?",[id])
        }
        return row.count > 0 ? row[0] : nil
    }
    
    //检查用户名和邮箱是否被注册
    public static func query_by_email_and_username(email:String,username:String)throws -> (Bool,Int?) { //0为email 1为username
        let row:[UserEntity] = try pool.execute({ conn in
            try conn.query("select * from user where username=? or email=? limit 1",[username,email]);
        })
        if row.count > 0 {
            let user = row[0]
            if user.email == email {
                return (false,0)
            }else{
                return (false,1)
            }
        }else{
            return (true,nil)
        }
    }
    public static func login_by_email(email:String,password:String) throws -> [UserEntity] {
        
        let row:[UserEntity] = try pool.execute({ conn in
            try conn.query("select * from user where email=? and password=?",[email,password]);
        })
        return row
    }
    public static func query_by_email(email:String)throws -> UserEntity?{
        
        let row:[UserEntity] = try pool.execute({ conn in
            try conn.query("select * from user where email=? limit 1",[email]);
        })
        if  row.count > 0{
            return row[0]
        }else{
            return nil
        }
    }
    
    //检查github 是否被注册
    public static func query_by_github_id(id:Int)throws -> UserEntity?{
        let row:[UserEntity] = try pool.execute({ conn in
            try conn.query("select * from user where github_id=? limit 1",[id]);
        })
        if row.count == 0 {
            return nil
        }else{
            return row[0]
        }
    }
    
    public static func update_verify(id:Int) throws -> Bool{
        let status: QueryStatus = try pool.execute{ conn in
            try conn.query("update user set is_verify=1 where id=?", [id])
        }
        if status.affectedRows > 0 {
            return true
        }else{
            return false
        }
    }
}
