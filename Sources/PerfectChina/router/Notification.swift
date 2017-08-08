import Foundation
import PerfectHTTP
import PerfectLib



class Notification {
    
    static func index(data: [String:Any]) throws -> RequestHandler {
        return {
            req, res in
            res.render(template: "user/notification")
        }
    }
    static func requiredDate(data: [String:Any]) throws -> RequestHandler {
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
