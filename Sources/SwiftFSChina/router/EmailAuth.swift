//
//  EmailAuth.swift
//  PerfectChina
//
//  Created by mubin on 2017/8/13.
//
//

import Foundation
import PerfectSMTP
import PerfectLib
import PerfectHTTP

class EmailAuth{
    
    static func send_verification_mail(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            do{
                
            if let user:[String:Any] = req.session?.data["user"] as? [String:Any] {
                let username:String? = user["username"] as? String
                let email:String? = user["email"] as? String
                if username == nil || email == nil {
                    res.redirect(path: "/")
                    return
                }
                EmailAuth.sentAuth(send_name: username!, send_email: email!)
                res.redirect(path: "/user/\(username!)/index")
            }
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }

    static func email_verification(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            
            guard let user:[String:Any] = req.session?.data["user"]  as? [String:Any] else{
                res.render(template: "login")
                return
            }
            guard let email:String = user["email"] as? String else{
                res.render(template: "login")
                return
            }
            
            res.render(template: "email-verification"
                ,context: ["email":email])
        }
    }
    
    static func verification(data: [String:Any]) throws -> RequestHandler {
        return  {
            req,res in
            do{
                
                let secret = req.urlVariables["secret"]
                //使用用户名作加密验证
                guard let email = req.param(name: "email")?.string else{
                    
                    return
                }
                
                guard  let user = try UserServer.query_by_email(email: email) else{
                    
                    return
                }
                
                let encodeUserSt = Utility.encode(message: user.username)
                
                guard encodeUserSt == secret else{
                    return
                }
                
                 _ = try UserServer.update_verify(id: user.id.id.id)
                
                req.session?.data["is_verify"] = 1
                res.sessionRedirect(path: "/index", session: req.session!)
                
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    
    
    
    static func sentAuth(send_name:String,send_email:String){
        
        // setup the mail server login information, *NOTE* please modify these information
        let client = SMTPClient(url: STMPConfig.url, username: STMPConfig.username, password:STMPConfig.password)
        
        // draft an email
        var email = EMail(client: client)
        
        // set the subject
        email.subject = "请激活您的邮箱"
        
        // set the sender
        email.from = Recipient(name: "SwiftFS", address: STMPConfig.username)
        
        //encodeName
        let encodeUsername = Utility.encode(message: send_name)
        
        
        // set the html content
        let skip = "\(ApplicationConfiguration.init().baseURL)/verification/\(String(describing: encodeUsername!))?email=\(send_email)"
        email.content = "<p>Hi \(send_name)，欢迎加入 SwiftFS China 社区。这里是SwiftWeb开发" + "社区，致力于打造SwiftWeb开发 为开发者提供一个分享创造、结识伙伴、协同互助的平台!</p></br>" +
            "<p>为了保证社区功能的正常使用，请点击以下链接激活账号:</p>" +
            "<a href='\(skip)'>\(skip)</a>"
        
        email.to.append(Recipient(address: send_email))
        
        
        // attach some files, *NOTE* please change to your local files instead.
        //email.attachments.append("/tmp/hello.txt")
        //email.attachments.append("/tmp/welcome.png")
        
        var wait = true
        do {
            try email.send { code, header, body in
                Log.info(message: "\(code)")
                wait = false
            }//end send
        }catch(let err) {
            Log.error(message: "\(err)")
        }//end do
        
        while(wait) {
            sleep(1)
        }//end while
    }
}
