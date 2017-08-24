//
//  Topic.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/29.
//
//

import Foundation
import PerfectHTTP
import PerfectLib



class Topic {
    
    static func edit(data: [String:Any]) throws -> RequestHandler{
        return {
            req,res in
            do{
                let category_id = req.param(name: "category_id")?.int
                let title = req.param(name: "title")
                let content = req.param(name: "content")
                let topic_id = req.param(name: "topic_id")?.int
                
                guard topic_id != nil && category_id != nil else{
                    try res.setBody(json: ["success":false,"errMsg":"参数错误，要编辑的文章不存在"])
                    res.completed()
                    return
                }
                
                guard title != "" && content != "" else{
                    try res.setBody(json: ["success":false,"errMsg":"标题和内容不得为空"])
                    res.completed()
                    return
                }
                
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                guard let user_id = user?["userid"] as? Int else {
                    res.render(template: "error", context: ["errMsg":"编辑文章请先登录"])
                    return
                }
                
                let judge = try TopicServer.update(topic_id: topic_id!, title: title!, content: content!, user_id: user_id, category_id: category_id!)
                
                if judge == true {
                    try res.setBody(json: ["success":true,"msg":"更新文章成功","data":["id":topic_id!]])
                    res.completed()
                }else{
                    try res.setBody(json: ["success":false,"msg":"更新文章错误"])
                    res.completed()
                }
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }

    
    static func edit_topic(data: [String:Any]) throws -> RequestHandler{
        return {
            req,res in
            do{
                
                guard let topic_id = req.urlVariables["topic_id"]?.int else{
                    res.render(template: "error", context: ["errMsg":"参数错误"])
                    return
                }
                
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                guard let user_id = user?["userid"] as? Int else {
                    res.render(template: "error", context: ["errMsg":"编辑文章请先登录"])
                    return
                }
                let row =  try TopicServer.get_my_topic(user_id: user_id, id: topic_id)
                guard row.count > 0 else {
                    res.render(template: "error", context: ["errMsg":"您要编辑的文章不存在或者您没有权限编辑."])
                    return
                }
                
                let rowjson:[String:Any]! = row[0].toJSON()
                res.render(template: "topic/edit", context: ["topic":rowjson])
                
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }

    
    static func delete_topic(data: [String:Any]) throws -> RequestHandler{
        return {
            req,res in
            do{
                guard let topic_id = req.urlVariables["topic_id"]?.int else{
                    try res.setBody(json: ["success":false,"msg":"参数错误"])
                    res.completed()
                    return
                }
                
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                guard let user_id = user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"操作之前请先登录"])
                    res.completed()
                    return
                }
                
                let judge = try TopicServer.delete_topic(user_id: user_id, topic_id: topic_id)
                if judge == true {
                   try res.setBody(json: ["success":true,"msg":"删除文章成功"])
                    res.completed()
                }else{
                    try res.setBody(json: ["success":false,"msg":"删除文章失败"])
                    res.completed()
                }
                
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }

    
    static func cancel_collect(data: [String:Any]) throws -> RequestHandler{
        return {
            req,res in
            do{
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                guard let user_id = user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"操作之前请先登录"])
                    res.completed()
                    return
                }
                let topic_id = req.param(name: "topic_id")?.int ?? 0
                let judge =  try CollectServer.cancel_collect(user_id: user_id, topic_id: topic_id)
                if judge == true {
                    try res.setBody(json: ["success":true,"msg":"cancel collect successfully."])
                    res.completed()
                }else{
                    try res.setBody(json: ["success":false,"msg":"cancel collect error."])
                    res.completed()
                }

            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    static func collect(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            do {
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                guard let user_id = user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"操作之前请先登录"])
                    res.completed()
                    return
                }
                let topic_id = req.param(name: "topic_id")?.int ?? 0
                let judge =  try CollectServer.collect(user_id: user_id, topic_id: topic_id)
                if judge == true {
                    try res.setBody(json: ["success":true,"msg":"collect successfully."])
                    res.completed()
                }else{
                    try res.setBody(json: ["success":false,"msg":"collect error."])
                    res.completed()
                }
                
            }catch{
                Log.error(message: "\(error)")
            }
            
        }
    }
    
    static func like(data: [String:Any]) throws -> RequestHandler {
        return  {
            req,res in
            do {
            let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
            guard let user_id = user?["userid"] as? Int else {
                try res.setBody(json: ["success":false,"msg":"操作之前请先登录"])
                res.completed()
                return
            }
            let topic_id = req.param(name: "topic_id")?.int ?? 0
            let judge = try LikeServer.like(user_id: user_id, topic_id: topic_id)
            if judge {
                try res.setBody(json: ["success":true,"msg":"like successfully."])
                res.completed()
            }else{
                try res.setBody(json: ["success":false,"msg":"login before update."])
                res.completed()
            }
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    static func isself(req:HTTPRequest,uid:Int) -> Bool{
        var result = false
        if  (req.session != nil) && (req.session?.data["user"] != nil) {
            let user:[String:Any] = req.session!.data["user"] as! [String : Any]
            
            let userid = user["userid"] as! Int
            if uid == userid {
                result = true
            }
        }
        return result
    }
    
    static func new(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
//            Utils.days_after_registry(req: req)
            
            res.render(template: "topic/new")
        }
    }
    
    static func newTopic(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            let category_id:Int = req.param(name: "category_id")?.int ?? 0
            let title = req.param(name: "title")
            let content = req.param(name: "content")
            let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
            
            do{
                guard let user_id = user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"请先登录"])
                    res.completed()
                    return
                }
                
                guard let user_name = user?["username"] as? String else {
                    try res.setBody(json: ["success":false,"msg":"请先登录"])
                    res.completed()
                    return
                }
                
                guard title != nil && content != nil && content != "" && title != "" && category_id != 0 else {
                    try res.setBody(json: ["success":false,"msg":"title and content should not be empty"])
                    res.completed()
                    return
                }
                let insertedID =  try TopicServer.new(title: title!, content: content!, user_id: user_id, user_name: user_name, category_id: category_id)
                
                if insertedID == nil {
                    try res.setBody(json: ["success":false,"msg":"保存失败"])
                    res.completed()
                    return
                }else{
                    try res.setBody(json: ["success":true,"msg":"保存成功","data":["id":insertedID]])
                    res.completed()
                    return
                }
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    static func get(data: [String:Any]) throws -> RequestHandler {
        return {
            req, res in
            
            let topic_id = req.urlVariables["topic_id"]
            res.render(template: "topic/view", context: ["topic":["id":topic_id!]])
        }
    }
    
    static func getQuery(data: [String:Any]) throws -> RequestHandler {
        return {
            req, res in
            let topic_id = req.urlVariables["topic_id"]
            do {
                guard (topic_id != nil) else{
                    try res.setBody(json: ["success":false,"msg":"要查询的文章id不能为空"])
                    res.completed()
                    return
                }
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                let current_userid = user?["userid"]
                var is_collect = false
                var is_like = false
                
                if "\(String(describing: current_userid))".int != nil && "\(current_userid!)".int! != 0 {
                    is_collect = try CollectServer.is_collect(current_userid: "current_userid".int!, topic_id: topic_id!)
                    is_like = try LikeServer.is_like(current_userid: "current_userid".int!, topic_id: (topic_id?.int!)!)
                }
                
                guard ((topic_id?.int) != nil) else {
                    try res.setBody(json: ["success":false,"msg":"无法查到当前文章"])
                    res.completed()
                    return
                }
                
                let row =  try TopicServer.get(id: (topic_id!.int)!)
                guard row.count >= 1 else{
                    try res.setBody(json: ["success":false,"msg":"无法查到当前文章"])
                    res.completed()
                    return
                }
                let topic = row[0]
                let is_self = Topic.isself(req: req, uid:topic.user_id)
                
                let topicArr = topic.toJSON()!
                
                
                try res.setBody(json: ["success":true,"data":["topic":topicArr,"is_self":is_self,"meta":["is_collect":is_collect,"is_like":is_like]]])
                
                res.completed()
                

                
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
}
