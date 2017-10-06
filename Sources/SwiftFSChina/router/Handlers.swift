//
//  Handlers.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/25.
//
//

import Foundation
import PerfectHTTP
import PerfectLib


class Handlers {
    
    static func topics_category_handler(current_category:Int,request:HTTPRequest,response:HTTPResponse) {
            var context: [String : Any] = [:]
            do{
                let user_count = try UserServer.get_total_count()
                context["user_count"] = user_count[0].count
                let topic_count = try TopicServer.get_total_count()
                context["topic_count"] = topic_count[0].count
                let comment_count = try CommentServer.get_total_count()
                context["comment_count"] = comment_count[0].count
                let (diff,diff_days) = Utils.days_after_registry(req: request)
                
                context["diff"] = diff
                context["diff_days"] = diff_days
                context["current_category"] = current_category
            }catch{
                
            }
            response.render(template: "index",context: context)
    }
    
    
    static func settings(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            guard let user:[String:Any] = request.session?.data["user"] as? [String : Any] else{
                response.render(template: "error", context: ["errMsg":"cannot find user, please login."])
                return
            }
            
            guard let userId = user["userid"]  else {
                response.render(template: "error", context: ["errMsg":"cannot find user, please login."])
                return
            }
            
            do{
                let user = try UserServer.query_by_id(id: "\(userId)".int!)
                let encoded = try? encoder.encode(user)
                if encoded != nil {
                    if let json = encodeToString(data: encoded!){
                        if let decoded = try json.jsonDecode() as? [String:Any] {
                            response.render(template: "user/settings", context: ["user":decoded])
                        }
                    }
                }
            }catch{
                response.render(template: "error", context: ["errMsg":"error to find user."])
            }
            
        }
    }
    
    
    
    static func index(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            let current_category = 0
            if let loginType:String = request.session?.data["loginType"] as? String{
                if loginType == "github" {
                    
                }
            }
            
            Handlers.topics_category_handler(current_category: current_category,request: request,response:response)
        }
    }
    
    static func share(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            let current_category = 1
            Handlers.topics_category_handler(current_category: current_category,request: request,response:response)
        }
    }
    
    static func ask(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            let current_category = 2
            Handlers.topics_category_handler(current_category: current_category,request: request,response:response)
        }
    }

    
    static func login(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in

            response.render(template: "login")
           
        }
    }
    static func register(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            
            let name = request.session?.data["name"] ?? ""
            let email = request.session?.data["email"] ?? ""
            let picture_url = request.session?.data["picture"] ?? ""
            let login = request.session?.data["login"] ?? ""
            
            let content:[String:Any] = ["name":name,"email":email,"picture_url":picture_url,"login":login]
            response.render(template: "register",context: content)
        }
    }
    
    static func about(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            
            response.render(template: "about")
           
        }
    }

}
