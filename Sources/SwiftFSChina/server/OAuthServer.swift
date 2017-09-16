//
//  CollectServer.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//


import PerfectLib
import MySQL


class OAuthServer {
    
    class func verify_autho(git_id:Int) throws -> UserEntity? {
        return nil
        
        let row:[UserEntity] = try pool.execute({ conn in
            try conn.query("select count(c.id) as count from collect c " +
                " where c.user_id=? and c.topic_id=?",[])
        })
        if row.count > 0 {
            return row[0]
        }else{
            return nil
        }
    }
}
