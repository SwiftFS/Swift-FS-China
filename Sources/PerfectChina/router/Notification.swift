import Foundation
import PerfectHTTP
import PerfectLib

protocol RequestLogin {
    static func detectLogin(_ req:HTTPRequest,_ res:HTTPResponse)->Int?
}
extension RequestLogin{
    static func detectLogin(_ req:HTTPRequest,_ res:HTTPResponse)->Int?{
        defer{
            res.completed()
        }
        do{
            guard let user = req.session?.data["user"] as? [String : Any] else{
                try res.setBody(json: ["success":false,"msg":"操作之前请先登录"])
                return nil
            }
            guard let user_id = user["userid"] as? Int else {
                try res.setBody(json: ["success":false,"msg":"获取用户id失败"])
                return nil
            }
            return user_id
        }
        catch{
            Log.error(message: error.localizedDescription)
        }
        return nil
    }
}

struct Notification:RequestLogin{
    
    public static func mark(data: [String:Any]) throws -> RequestHandler {
        return {
            req, res in
            do{
//                guard let user:[String:Any] = req.session?.data["user"] as? [String : Any] else{
//                    return
//                }
//                guard let user_id:Int = user["userid"] as? Int  else {
//                    try res.setBody(json: ["success":false,"msg":"操作之前请先登录"])
//                    res.completed()
//                    return
//                }
                
//                let judge = try NotificationServer.update_status(user_id: user_id)
//                guard  judge != false else {
//                    try res.setBody(json: ["success":false,"msg":"标记失败"])
//                    res.completed()
//                    return
//                }
//                try res.setBody(json: ["success":true,"msg":"标记成功"])
//                res.completed()
                defer {
                    res.completed()
                }
                guard let user_id = detectLogin(req, res), try NotificationServer.update_status(user_id: user_id) else {
                    try res.setBody(json: ["success":false,"msg":"标记失败"])
                    return
                }
                try res.setBody(json: ["success":true,"msg":"标记成功"])
            }catch{
                Log.error(message: error.localizedDescription)
            }
        }
    }
    
    public static func index(data: [String:Any]) throws -> RequestHandler {
        return {
            req, res in
            res.render(template: "user/notification")
        }
    }
    static func delete(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            do{
                guard let user:[String:Any] = req.session?.data["user"] as? [String : Any] else{
                    return
                }
                guard let user_id:Int = user["userid"] as? Int  else {
                    try res.setBody(json: ["success":false,"msg":"操作之前请先登录"])
                    res.completed()
                    return
                }
                
                guard let id = req.urlVariables["id"]?.int else{
                    try res.setBody(json: ["success":false,"msg":"删除的id不存在"])
                    res.completed()
                    return
                }
                
                let judge = try NotificationServer.delete(id: id, user_id: user_id)
                
                guard judge != false else{
                    try res.setBody(json: ["success":false,"msg":"删除通知失败"])
                    res.completed()
                    return
                }
                
                try res.setBody(json: ["success":true,"msg":"删除通知成功"])
                res.completed()
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    public static func delete_all(data: [String:Any]) throws -> RequestHandler {
        return  {
            req,res in
            do{
                
                guard let user:[String:Any] = req.session?.data["user"] as? [String : Any] else{
                    return
                }
                
                guard let user_id:Int = user["userid"] as? Int  else {
                    try res.setBody(json: ["success":false,"msg":"操作之前请先登录"])
                    res.completed()
                    return
                }
                
                let result = try NotificationServer.delete_all(user_id: user_id)
                guard result != false else{
                    try res.setBody(json: ["success":false,"msg":"没有数据或删除失败"])
                    res.completed()
                    return
                }
                
                try res.setBody(json: ["success":true,"msg":"删除所有通知成功"])
                res.completed()
                
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    public static func requiredDate(data: [String:Any]) throws -> RequestHandler {
        return {
            req, res in
            do{
                
                let page_no = req.param(name: "page_no")
                var n_type = req.param(name: "n_type")
                let page_size = notification_page_size
                
                guard let user:[String:Any] = req.session?.data["user"] as? [String : Any] else{
                    try res.setBody(json: ["success":false,"msg":"查询通知之前请先登录"])
                    res.completed()
                    return
                }
                if (n_type != nil) && n_type == ""{
                    n_type = "all"
                }
                
                guard let user_id:Int = user["userid"] as? Int  else {
                    try res.setBody(json: ["success":false,"msg":"获取用户id失败"])
                    res.completed()
                    return
                }
                
                let total_cout =  try NotificationServer.get_total_count(user_id: user_id, n_type: n_type!)
                let total_page =  Utils.total_page(total_count: total_cout, page_size: page_size)
                
                let notifications = try NotificationServer.get_all(user_id: user_id, n_type: n_type!, page_no: page_no!, page_size: page_size)
                
                try res.setBody(json: ["success":true,"data":["totalCount":total_cout,"totalPage":total_page,"currentPage":page_no!,"notifications":notifications.toJSON()]])
                res.completed()
            }catch{
                Log.error(message: "\(error)", evenIdents: true)
            }
            
        }
    }
}
