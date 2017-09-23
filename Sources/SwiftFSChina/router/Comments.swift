//
//  Topics.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/29.
//
//

import Foundation
import PerfectHTTP
import PerfectLib


class Comments {
    
    static func delete(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            do {
                
                guard let comment_id = req.urlVariables["comment_id"]?.int else {
                    try res.setBody(json: ["success":false,"msg":"获取删除评论ID失败"])
                    res.completed()
                    return
                }
                
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                
                guard let user_id = user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"请先登录"])
                    res.completed()
                    return
                }
                let comment  = try CommentServer.query(comment_id: comment_id)
                
                let judge =  try CommentServer.delete(user_id: user_id, comment_id: comment_id)
                
                guard judge != false else{
                    try res.setBody(json: ["success":false,"msg":"删除评论失败"])
                    res.completed()
                    return
                }
                //重置评论
                if (comment != nil) && comment?.topic_id != 0{
                    let topic_id =  comment?.topic_id
                    let _ = try CommentServer.reset_topic_comment_num(topic_id: topic_id!)
                    let last_reply = try CommentServer.get_last_reply_of_topic(topic_id: topic_id!)
                    
                    if (last_reply != nil) && last_reply?.user_id != 0 {
                        try TopicServer.reset_last_reply(topic_id: topic_id!, user_id: user_id, user_name: last_reply!.user_name, last_reply_time: last_reply!.create_time)
                        
                    }else{
                        try TopicServer.reset_last_reply(topic_id: topic_id!, user_id: 0, user_name: "", last_reply_time: Date.init())
                    }
                }
                try res.setBody(json: ["success":true,"msg":"删除评论成功"])
                res.completed()
                
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    static func newComment(data: [String:Any]) throws -> RequestHandler {
        return {
            req, res in
            do{

                let topic_id:Int = req.param(name: "topic_id")?.int ?? 0
                let content = req.param(name: "content")
                let mention_users = req.param(name: "mention_users")
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                
                guard let user_id = user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"操作之前请先登录"])
                    res.completed()
                    return
                }
                
                if (topic_id == 0) || (content == nil) || (content == "") {
                    try res.setBody(json: ["success":false,"msg":"参数不得为空"])
                    res.completed()
                    return
                }
                
                var musArr: [String]?
                
                if mention_users != nil {
                    
                let splite = NSString(string: mention_users!)
                 musArr  = splite.components(separatedBy: ",")
                    if musArr!.count > 5 {
                        try res.setBody(json: ["success":false,"msg":"评论设计的人最多只能有5个"])
                    }
                
                }
                
                let insert_id = try CommentServer.new(topic_id: topic_id, user_id: user_id, content: content!)
                guard insert_id != nil else{
                    try res.setBody(json: ["success":false,"msg":"保存评论失败"])
                    res.completed()
                    return
                }
                let new_comment_id = Int(insert_id!)
                
                let _ = try CommentServer.reset_topic_comment_num(topic_id: topic_id)
                
                let last_reply = try CommentServer.get_last_reply_of_topic(topic_id: topic_id)
                
                if last_reply != nil && last_reply!.user_id != 0 {
                    try TopicServer.reset_last_reply(topic_id: topic_id, user_id: last_reply!.user_id, user_name: last_reply!.user_name, last_reply_time: last_reply!.create_time)
                }
                
                let new_comment = try CommentServer.query(comment_id: new_comment_id)
            
                //给评论发通知
                var clean_mus:[String] = []
                if musArr != nil && musArr!.count > 0 {
                    for (_,v) in musArr!.enumerated(){
                        if v != "" {
                            let after = "'\(v)'"
                            clean_mus.append(after)
                        }
                    }
                    
                    if clean_mus.count > 0 {
                        let usernames = clean_mus.joined(separator: ",")
                        if usernames != "" {
                            let row =  try UserServer.query_ids(username: usernames)
                            
                            if row != nil {
                                for u in  row! {
                                    try NotificationServer.comment_mention(user_id: u.id, from_id: user_id, content: "", topic_id: topic_id, comment_id: new_comment_id)
                                }
                            }
                        }
                    }
                }
                try NotificationServer.comment_notify(from_id: Int(user_id), content: "", topic_id: topic_id, comment_id: new_comment_id)
                try res.setBody(json: ["success":true,"msg":"保存评论成功","data":["c":new_comment!.toJSON()]])
                res.completed()
                
            }catch{
                Log.error(message: "\(error)")
                return
            }
        }
    }

    //获取文章
    static func getComments(data: [String:Any]) throws -> RequestHandler {
        return {
            req, res in
            
            do{
            
            let page_no:Int = req.param(name: "page_no")?.int ?? 1
            let topic_id = req.param(name: "topic_id")?.int ?? 0
            let page_size = page_config.topic_comment_page_size
            let total_count = try CommentServer.get_total_count_of_topic(topic_id: topic_id)
            let total_page = Utils.total_page(total_count: total_count, page_size: page_size)
                
            let comments = try CommentServer.get_all_of_topic(topic_id: topic_id, page_no: page_no, page_size: page_size)
                
            let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
            
            let user_id:Int = user?["userid"] as? Int ?? 0
            
            let data: [String : Any] = ["totalCount":total_count,
                                        "totalPage":total_page,
                                        "currentPage":page_no,
                                        "comments":comments.toJSON(),
                                        "base":(page_no - 1) * page_size,
                                        "current_user_id":user_id]
                
            try res.setBody(json: ["success":true,"data":data])
                res.completed()
            }catch{
                
                Log.error(message: "\(error)")
                return
            }
        }
    }
}
