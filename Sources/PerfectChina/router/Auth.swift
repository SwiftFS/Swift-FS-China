//
//  Auth.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/26.
//
//


import Foundation
import PerfectHTTP
import PerfectLib
import BCrypt
import PerfectSession


class Auth {
    
    static func logout(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
                guard (req.session != nil) else {
                    res.redirect(path: "/index")
                    return
                }
            
                let sessionDic:[String:Any] = ["username":"",
                                               "login":false,
                                               "userid":0,
                                               "create_time":""]
                req.session!.data.updateValue(sessionDic, forKey: "user")
                res.redirect(path: "/index")
            
        }
    }
    
    //登录
    static func login(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            let username = req.param(name: "username")
            var password = req.param(name: "password")
            do{
                guard username != nil && password != nil else {
                    try res.setBody(json: ["success": false,"msg":"用户名和密码不得为空."])
                    res.completed()
                    return
                }
                password = Utility.encode(message: password!)
                var isExist = false
                var user:UserEntity?
                
                let users =  try UserServer.query(username: username!, password: password!)
                if users.count > 0 {
                    isExist  = true
                    user = users[0]
                }
                
                guard isExist != false else {
                    try res.setBody(json: ["success":false,"msg":"用户名或密码错误，请检查!"])
                    res.completed()
                    return
                }
                
                guard req.session != nil else {
                    try res.setBody(json: ["success":false,"msg":"withhout session"])
                    return
                }
                //配置sesssion
                let sessionDic:[String:Any] = ["username":user!.username,
                                               "userid":user!.id.id.id,
                                               "create_time":user!.create_time ?? ""]
                req.session!.data.updateValue(sessionDic, forKey: "user")
                try res.setBody(json: ["success":true,"msg":"登录成功"])
                res.completed()
            }catch{
            Log.error(message: "\(error)")
            }
        }
    }
    
    
    
    static func signUp(data: [String:Any]) throws -> RequestHandler {
        return {
            req, res in
            do{
                let username = req.param(name: "username")
                let password = req.param(name: "password")
                let pattern = "^[a-zA-Z][0-9a-zA-Z_]+$"
                let userPattern = Regex.init(pattern)
                guard username != nil && password != nil else {
                    try res.setBody(json: ["success": false,"msg":"用户名和密码不得为空."])
                    res.completed()
                    return
                }
                
                guard username!.length > 4 && password!.length > 4 else{
                    try res.setBody(json: ["success": false,"msg":"密码长度应为6~50位."])
                    res.completed()
                    return
                }
                
                guard userPattern.match(input: username!) != false else {
                    try res.setBody(json: ["success": false,"msg":"用户名只能输入字母、下划线、数字，必须以字母开头."])
                    res.completed()
                    return
                }
                var isRegistered:Bool!   //是否以及注册
                
                isRegistered = try UserServer.query_by_username(username: username!)
                guard isRegistered == false else {
                    try res.setBody(json: ["success": false,"msg":"用户名已被占用，请修改!"])
                    return
                }
                
                guard let encode_pwd = Utility.encode(message: password!) else {
                    try res.setBody(json: ["success": false,"msg":"加密失败"])
                    res.completed()
                    return
                }
                
                let avatar = username!.index(username!.startIndex, offsetBy: 1)
                let first_pic  = username!.substring(to: avatar) + ".png"
                
                let register =  try UserServer.new(username: username!, password: encode_pwd, avatar: first_pic)
                if register {
                    try res.setBody(json: ["success": true,"msg":"注册成功"])
                    res.completed()
                }else{
                    try res.setBody(json: ["success": false,"msg":"注册失败,未知错误"])
                    res.completed()
                }
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
}

