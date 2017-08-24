import Foundation
import PerfectHTTP
import PerfectLib

class User {
    
    static func change_pwd(data:[String:Any]) throws -> RequestHandler{
        return {
            req,res in
            do{
                
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                guard let user_id = user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"修改前请先登录."])
                    res.completed()
                    return
                }
                
                let old_pwd = req.param(name: "old_pwd")
                let new_pwd = req.param(name: "new_pwd")
                
                guard (old_pwd != nil) && (new_pwd != nil) else {
                    try res.setBody(json: ["success":false,"msg":"修改前请先登录."])
                    res.completed()
                    return
                }
                
                let password_len = new_pwd?.length
                
                guard password_len! >= 6 else {
                    try res.setBody(json: ["success":false,"msg":"密码长度应为6~50位."])
                    res.completed()
                    return
                }
                
                guard let userEntity:UserEntity =  try UserServer.query_by_id(id: user_id) else{
                    try res.setBody(json: ["success":false,"msg":"无法查找到该用户."])
                    res.completed()
                    return
                }
                
                guard userEntity.password.length > 0 && Utility.encode(message: old_pwd!) != Utility.encode(message: userEntity.password) else{
                    try res.setBody(json: ["success":false,"msg":"输入的当前密码不正确."])
                    res.completed()
                    return
                }
                //加盐
                guard let new_pwd_encode =  Utility.encode(message: new_pwd!) else{
                    try res.setBody(json: ["success":false,"msg":"加密失败"])
                    res.completed()
                    return
                }
                let judge = try UserServer.update_pwd(userid: user_id, new_pwd: new_pwd_encode)
                
                if !judge {
                    try res.setBody(json: ["success":false,"msg":"更改密码失败."])
                    res.completed()
                    return
                }else{
                    try res.setBody(json: ["success":true,"msg":"更改密码成功."])
                    res.completed()
                    return
                }
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    static func edit(data:[String:Any]) throws -> RequestHandler{
        return {
            req,res in
            do{
                
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                guard let user_id = user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"编辑前请先登录."])
                    res.completed()
                    return
                }
                let emmail = req.param(name: "email") ?? ""
                let email_public = req.param(name: "email_public")?.int ?? 0
                let city = req.param(name: "city") ?? ""
                let company = req.param(name: "company") ?? ""
                let github = req.param(name: "github") ?? ""
                let website = req.param(name: "website") ?? ""
                let sign = req.param(name: "sign") ?? ""
                
                let success =  try UserServer.update(user_id: user_id, email: emmail, email_public: email_public, city: city, company: company, github: github, website: website, sign: sign)
                
                if success == false {
                    try res.setBody(json: ["success":false,"msg":"失败"])
                        res.completed()
                }else{
                    try res.setBody(json: ["success":true,"msg":"编辑成功"])
                    res.completed()
                }
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    static func isself(req:HTTPRequest,uid:Int) -> Bool{
        var result = false
        if req.session?.data["user"] != nil{
            let user:[String:Any] = req.session!.data["user"] as! [String : Any]
            let userid:Int = user["userid"] as? Int ?? 0
            if (userid != 0) && uid == userid  {
                result =  true
            }
        }
        return result
    }
    
    static func fans(data:[String:Any]) throws -> RequestHandler{
        return {
            req,res in
            do{
                let username = req.urlVariables["username"]
                guard username != nil && username != nil else{
                    try res.setBody(json: ["success":false,"msg":"参数错误"])
                    res.completed()
                    return
                }
                
                let user:UserEntity? = try UserServer.query_by_username(username: username!)
                guard user != nil else{
                    try res.setBody(json: ["success":false,"msg":"无法查找到用户"])
                    res.completed()
                    return
                }
                let userid = user!.id.id.id
                let page_no:Int = req.param(name: "page_no")?.int ?? 0
                let page_size = 20
                let total_count = try CommentServer.get_total_count_of_user(user_id: userid)
                let total_page = Utils.total_page(total_count: total_count, page_size: page_size)

                let users = try FollowServer.get_fans_of_user(user_id: userid, page_no: page_no, page_size: page_size)
                let usersArr = users.toJSON() as! [[String:Any]]
                
                try res.setBody(json: ["success":true,
                                       "data":["totalCount":total_count,"totalPage":total_page,"currentPage":page_no,"users":usersArr]])
                
                res.completed()

            
            }catch{
                
            }
        }
    }
    
    static func cancel_follow(data:[String:Any]) throws -> RequestHandler{
        return{
            req,res in
            do{
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                guard let user_id = user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"修改前请先登录."])
                    res.completed()
                    return
                }
                
                guard let to_id = req.param(name: "to_id")?.int else{
                    try res.setBody(json: ["success":false,"msg":"参数错误."])
                    res.completed()
                    return
                }
                
                let judge = try FollowServer.cancel_follow(id1: user_id, id2: to_id)
                let relation = try get_relation(id1: user_id, id2: to_id)
                
                let query_follows = try FollowServer.get_follows_count(user_id: to_id)
                let count = query_follows[0].count
                
                let query_fans = try FollowServer.get_fans_count(user_id: to_id)
                let fans_count = query_fans[0].count
                
                guard judge != false else{
                    try res.setBody(json: ["success":false,"msg":"取消关注失败"])
                    res.completed()
                    return
                }
                
                try res.setBody(json: ["success":true,"msg":"取消关注成功","data":["relation":relation,"follows_count":count,"fans_count":fans_count]])
                res.completed()
                
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    static func follow(data:[String:Any]) throws -> RequestHandler{
        return{
            req,res in
            do {
                let user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                guard let user_id = user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"修改前请先登录."])
                    res.completed()
                    return
                }
                
                guard let to_id = req.param(name: "to_id")?.int else{
                    try res.setBody(json: ["success":false,"msg":"参数错误."])
                    res.completed()
                    return
                }
                
                let result =  try FollowServer.follow(id1: user_id, id2: to_id)
                let relation = try get_relation(id1: user_id, id2: to_id)
                
                let query_follows = try FollowServer.get_follows_count(user_id: to_id)
                let count = query_follows[0].count
                
                let query_fans = try FollowServer.get_fans_count(user_id: to_id)
                let fans_count = query_fans[0].count
                
                guard result == true else {
                    try res.setBody(json: ["success":false,"msg":"关注失败"])
                    res.completed()
                    return
                }
                
                try res.setBody(json: ["success":true,"msg":"关注成功","data":["relation":relation,"follows_count":count,"fans_count":fans_count]])
                res.completed()
                
            }catch{
                
            
            }
        }
    }
    
    static func follows(data:[String:Any]) throws -> RequestHandler{
        return {
            req,res in
            
            do{
            let username = req.urlVariables["username"]
            guard username != nil && username != nil else{
                try res.setBody(json: ["success":false,"msg":"参数错误"])
                res.completed()
                return
            }
            
            let user:UserEntity? = try UserServer.query_by_username(username: username!)
            guard user != nil else{
                try res.setBody(json: ["success":false,"msg":"无法查找到用户"])
                res.completed()
                return
            }
                
            let userid = user!.id.id.id
            let page_no:Int = req.param(name: "page_no")?.int ?? 0
            let page_size = 20
            let total_count = try CommentServer.get_total_count_of_user(user_id: userid)
            let total_page = Utils.total_page(total_count: total_count, page_size: page_size)
            let users = try FollowServer.get_follows_of_user(user_id: userid, page_no: page_no, page_size: page_size)
            
            let usersArr = users.toJSON() as! [[String:Any]]
            try res.setBody(json: ["success":true,
                                      "data":["totalCount":total_count,"totalPage":total_page,"currentPage":page_no,"users":usersArr]])
                
            res.completed()
                
            }catch{
                Log.error(message: "\(error)")
            }
            
        }
    }
    
    static func collects(data:[String:Any]) throws -> RequestHandler{
        return{
            req,res in
            do{
                let username = req.urlVariables["username"]
                guard username != nil && username != nil else{
                    try res.setBody(json: ["success":false,"msg":"参数错误"])
                    res.completed()
                    return
                }
                
                let user:UserEntity? = try UserServer.query_by_username(username: username!)
                guard user != nil else{
                    try res.setBody(json: ["success":false,"msg":"无法查找到用户"])
                    res.completed()
                    return
                }
                
                let userid = user!.id.id.id
                let page_no:Int = req.param(name: "page_no")?.int ?? 0
                let page_size = 20
                let total_count = try CommentServer.get_total_count_of_user(user_id: userid)
                let total_page = Utils.total_page(total_count: total_count, page_size: page_size)
                let topics = try CollectServer.get_all_of_user(user_id: userid, page_no: page_no, page_size: page_size)
                
                let topicsArr = topics.toJSON() as! [[String:Any]]
                let data = ["totalCount":total_count,"totalPage":total_page,"currentPage":page_no,"topics":topicsArr] as [String : Any]
                try res.setBody(json: ["success":true,"data":data])
                res.completed()
            
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    static func comments(data:[String:Any]) throws -> RequestHandler{
        return {
            req,res in
            do{
                guard let username = req.urlVariables["username"] else{
                    try res.setBody(json: ["success":false,"msg":"无法查找到用户"])
                    res.completed()
                    return
                }
                
                let user:UserEntity? = try UserServer.query_by_username(username: username)
                guard user != nil else{
                    try res.setBody(json: ["success":false,"msg":"无法查找到用户"])
                    res.completed()
                    return
                }
                let userid = user!.id.id.id
                let page_no:Int = req.param(name: "page_no")?.int ?? 0
                let page_size = 20
                let total_count = try CommentServer.get_total_count_of_user(user_id: userid)
                let total_page = Utils.total_page(total_count: total_count, page_size: page_size)
                let comments =  try CommentServer.get_all_of_user(user_id: userid, page_no: page_no, page_size: page_size)
                let is_self = isself(req: req, uid: userid)
                let commentsArr = comments.toJSON() as! [[String:Any]]

                
                try res.setBody(json: ["success":true,"data":["totalCount":total_count,"totalPage":total_page,"currentPage":page_no,"comments":commentsArr,"is_self":is_self]])
                res.completed()
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    
    static func topics(data: [String:Any]) throws -> RequestHandler{
        return{
            req,res in
            do{
                
            let username = req.urlVariables["username"]
                guard username != nil && username != "" else{
                    try res.setBody(json: ["success":false,"msg":"无法查找到用户"])
                    res.completed()
                    return
                }
                let user:UserEntity? = try UserServer.query_by_username(username: username!)
                guard user != nil else{
                    try res.setBody(json: ["success":false,"msg":"无法查找到用户"])
                    res.completed()
                    return
                }
                let userid = user!.id.id.id
                let page_no = req.param(name: "page_no")?.int ?? 0
                let page_size = 20
                
                let total_count = try TopicServer.get_total_count_of_user(user_id: userid)
                let total_page =  Utils.total_page(total_count: userid, page_size: page_size)
                let topics = try TopicServer.get_all_of_user(user_id: userid, page_no: page_no, page_size: page_size)
                
                let is_self = isself(req: req, uid: userid)

                let topicArr = topics.toJSON() as! [[String:Any]]

                try res.setBody(json: ["success":true,"data":["totalCount":total_count,"totalPage":total_page,"currentPage":page_no,"topics":topicArr,"is_self":is_self]])
                res.completed()
            }catch{
                Log.error(message: "\(error)")
            }
        }

    }
    
    static func get_relation(id1:Int,id2:Int) throws -> Int{
        var reloation = 0
        var is_follow = false
        var is_fan = false
        
        let relations = try FollowServer.get_relation(id1: id1, id2: id2)
        
        for (_,v) in relations.enumerated() {
            if v.from_id == id1 && v.to_id == id2{
                is_follow = true
            }else if v.from_id == v.to_id{
                is_fan = true
            }
        }
        if is_follow && is_fan {
            reloation = 3 //好友
        }else if is_follow && !is_fan {
            reloation = 1
        }else if !is_follow && is_fan{
            reloation = 2
        }
        
        
        return reloation
    }
    
    static func like_topics(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            do{
                
                let username = req.urlVariables["username"]
                guard username != nil && username != "" else{
                    try res.setBody(json: ["success":false,"msg":"参数错误"])
                    res.completed()
                    return
                }
                let user:UserEntity? =  try UserServer.query_by_username(username: username!)
                guard user != nil else{
                    try res.setBody(json: ["success":false,"msg":"无法查找到用户"])
                    res.completed()
                    return
                }
                let page_no = req.param(name: "page_no")
                let page_size = 20
                let userid = user!.id.id.id
                let total_count = try TopicServer.get_total_count_of_user(user_id: userid)
                let total_page = Utils.total_page(total_count: total_count, page_size: page_size)
                let topics = try TopicServer.get_all_of_user(user_id: userid, page_no: 1, page_size: page_size)
                let is_self = User.isself(req: req, uid: userid)
                
                let topicsJSon = topics.toJSON() as! [[String:Any]]

                
                try res.setBody(json: ["success":true,"data":[
                                                        "totalCount":total_count,
                                                        "totalPage":total_page,
                                                        "currentPage":page_no ?? 0,
                                                        "topics":topicsJSon,
                                                        "is_self":is_self]])
                res.completed()
            }catch{
                Log.error(message: "\(error)")
            }
        }
     
    }
    
    static func hot_topics(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            do{
                
                let username = req.urlVariables["username"]
                guard username != nil && username != "" else{
                    try res.setBody(json: ["success":false,"msg":"参数错误"])
                        res.completed()
                    return
                }
                
                let user:UserEntity? =  try UserServer.query_by_username(username: username!)
                guard user != nil else{
                    try res.setBody(json: ["success":false,"msg":"无法查到用户"])
                        res.completed()
                    return
                }
                let page_no:Int! = req.param(name: "page_no")?.int ?? 0
                let page_size = 15
                let userid = user!.id.id.id
                
                let total_count = try TopicServer.get_total_hot_count_of_user(user_id: userid)
                let total_page = Utils.total_page(total_count: total_count, page_size: page_size)
                let topics = try TopicServer.get_all_hot_of_user(user_id: 2, page_no: page_no, page_size: page_size)
                
                
                let topicArr = topics.toJSON() as! [[String:Any]]
                
                let data = ["totalCount":total_count,
                            "totalPage":total_page,
                            "currentPage":page_no,
                            "topics":topicArr] as [String : Any]
                
            
                
                try res.setBody(json: ["success":true,"data":data])
                res.completed()
                
                
            }catch{
                Log.error(message: "\(error)")
                
            }
        }
    }
    //个人主页
    static func index(data: [String:Any]) throws -> RequestHandler {
        return {
            req, res in
            
            do {
            guard (req.session) != nil else{
                res.render(template: "error", context: ["errMsg":"请先登录"])
                return
            }
            let current_user:[String:Any]? = req.session!.data["user"] as? [String : Any]
            let current_userId:Int = current_user?["userid"] as? Int  ?? 0
            let username = req.urlVariables["username"]
            
            guard username != nil && username != "" else {
                res.render(template: "error", context: ["errMsg":"无法查找到用户"])
                return
            }
                
            guard let user:UserEntity = try UserServer.query_by_username(username: username!) else{
                res.render(template: "error", context: ["errMsg":"无法查找到用户"])
                res.completed()
                return
            }
                
            let userId = user.id.id.id
//            填充数据
            //粉丝
            let floows_count =  try FollowServer.get_follows_count(user_id: userId)
            //关注
            let fans_count  = try FollowServer.get_fans_count(user_id: userId)
            //文章数
            let topics_count = try TopicServer.get_total_count_of_user(user_id: userId)
                
            var is_self = false
            var relation = 0
                
            if current_userId != 0 {
                    is_self = current_userId == userId
                    relation = try User.get_relation(id1: current_userId, id2: userId)
            }
                
            let userJson = user.toJSON()!
            Log.info(message: "\(userJson)", evenIdents: true)
                                
            res.render(template: "user/index"
                        ,context: ["is_self":is_self
                                  ,"relation":relation
                                  ,"user":userJson
                                  ,"follows_count":floows_count[0].count
                                  ,"fans_count":fans_count[0].count
                                  ,"topics_count":topics_count])
            }catch{
                res.render(template: "error", context: ["errMsg":"\(error)"])
            }
        }
    }
}
