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
import PerfectCURL


class Auth {
    
    static func emailAuth(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            
        }
    }
    
    static func logout(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            
                guard (req.session != nil) else {
                    res.redirect(path: "/index")
                    return
                }
            
                let sessionDic:[String:Any] = ["username":"",
                                               "login":false,
                                               "userpic":"",
                                               "email":"",
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
            
            let email = req.param(name: "email")
            var password = req.param(name: "password")
            
            do{
                guard email != nil && password != nil else {
                    try res.setBody(json: ["success": false,"msg":"用户名和密码不得为空."])
                    res.completed()
                    return
                }
                
                let email_pattern = "^([a-zA-Z0-9]+([._\\-])*[a-zA-Z0-9]*)+@([a-zA-Z0-9])+(.([a-zA-Z])+)+$"
                let emailRegex = Regex.init(email_pattern)
                guard email != nil && emailRegex.match(input: email!) != false else {
                    try res.setBody(json: ["success": false,"msg":"请输入正确的邮箱地址"])
                    res.completed()
                    return
                }
                
                password = Utility.encode(message: password!)
                var isExist = false
                var user:UserEntity?
                
                let users =  try UserServer.login_by_email(email: email!, password: password!)
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
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current //设置时区，时间为当前系统时间
                //输出样式
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let ct = user!.create_time
                let stringDate = dateFormatter.string(from:ct!)
                
                //配置sesssion
                let sessionDic:[String:Any] = ["username":user!.username,
                                               "userid":user!.id.id.id,
                                               "userpic":user!.avatar,
                                               "create_time":stringDate]
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
                let email = req.param(name: "email")
                let github_name = req.param(name: "github_name") ?? ""
                
                
                
                guard let id:String = req.session?.data["id"] as? String,id.int != nil  else{
                    try res.setBody(json: ["success": false,"msg":"获取github资料出错"])
                    res.completed()
                    return
                }
                
                let pattern = "^[a-zA-Z][0-9a-zA-Z_]+$"
                let userPattern = Regex.init(pattern)
                guard username != nil && password != nil else {
                    try res.setBody(json: ["success": false,"msg":"用户名和密码不得为空."])
                    res.completed()
                    return
                }
                //邮箱验证
                let email_pattern = "^([a-zA-Z0-9]+([._\\-])*[a-zA-Z0-9]*)+@([a-zA-Z0-9])+(.([a-zA-Z])+)+$"
                let emailRegex = Regex.init(email_pattern)
                guard email != nil && emailRegex.match(input: email!) != false else {
                    try res.setBody(json: ["success": false,"msg":"请输入正确的邮箱地址"])
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
                
                
                let user_judge = try UserServer.query_by_github_id(id: id.int!)
                guard user_judge == nil else{
                    try res.setBody(json: ["success": false,"msg":"用户已被注册"])
                    res.completed()
                    return
                }
                
                //检查用户名和邮箱
                let (judge,type) = try UserServer.query_by_email_and_username(email: email!, username: username!)
                guard judge != false else {
                    if type == 0 {
                        try res.setBody(json: ["success": false,"msg":"邮箱已被占用"])
                        res.completed()
                    }else{
                        try res.setBody(json: ["success": false,"msg":"用户名已被占用"])
                        res.completed()
                    }
                    return
                }
                
                guard let encode_pwd = Utility.encode(message: password!) else {
                    try res.setBody(json: ["success": false,"msg":"加密失败"])
                    res.completed()
                    return
                }
                
                //如果获取不到图片地址 上传 字母图片
                let pic_url = req.session?.data["picture"] as? String
                //图片名称
                let avatar = username!.index(username!.startIndex, offsetBy: 1)
                var first_pic  = username!.substring(to: avatar) + ".png"
                
                let date = NSDate()
                let timeInterval = date.timeIntervalSince1970
                if pic_url != nil {
                    let hashName = "\(timeInterval.hashValue)"
                    first_pic = "\(hashName).jpg"
                    
                    let fileDir = Dir(Dir.workingDir.path + "webroot/avatar")
                    var uploadSuccess = false
                    //异步上传
                    CURLRequest(pic_url!).perform {
                        confirmation in
                        do {
                            
                            let response = try confirmation()
                            let bytes = response.bodyBytes
                            let data_pic = Data.init(bytes: bytes)
                            uploadSuccess = Utility.createFile(name: "\(hashName).jpg", fileBaseUrl: URL.init(fileURLWithPath: fileDir.path), data: data_pic)
                            if uploadSuccess != false {
                                first_pic = "\(hashName).jpg"
                            }
                        } catch let error as CURLResponse.Error {
                            Log.error(message: "出错，响应代码为： \(error.response.responseCode)")
                        } catch {
                            Log.error(message: "上传失败")
                        }
                    }
                    
                }
                
                guard let user_id =  try UserServer.new(username: username!, password: encode_pwd, avatar: first_pic, email: email!, github_id: id.int!, github_name: github_name) else{
                    try res.setBody(json: ["success": false,"msg":"注册失败,未知错误"])
                    res.completed()
                    return
                }
                
                guard let new_user =  try UserServer.query_by_id(id: user_id) else{
                    try res.setBody(json: ["success": false,"msg":"未知错误 001"])
                    res.completed()
                    return
                }
                
                //发送邮箱
                EmailAuth.sentAuth(send_name: new_user.username, send_email: new_user.email)
                try res.setBody(json: ["success": true,"msg":"注册成功"])
                res.completed()
                
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
}

