//
//  Filter404.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/25.
//
//
import PerfectHTTP
import PerfectLib


//检查有没登录
public func CheckLogin(data: [String:Any]) throws -> HTTPRequestFilter {
    
    return checklogin()
}


struct checklogin:HTTPRequestFilter {
    
    func is_login(req:HTTPRequest) -> [String:Any]? {
        
        guard let session = req.session,let user = session.data["user"] as? [String : Any] else {
            return nil
        }
        return user
    }
    
    func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
        
        //重定向
        guard request.path != "/to/github" else {
            callback(.execute(request, response))
            return
        }
        
        guard let st = request.header(.accept) else{
            callback(.execute(request, response))
            return
        }
        guard st.components(separatedBy: "text/html").count > 1 else {
            callback(.execute(request, response))
            return
        }

        
        let requestPath = request.path
        var in_white_list = false
        var islogin = false     //已经登录
        
        
        if requestPath == "/" || requestPath == "//"{
            in_white_list = true
        }else{
            for address in whitelist{
                let judge = Regex(address).match(input: requestPath)
                if judge == true {
                    in_white_list = true
                    break
                }
            }
        }

        //判断是否登录
        
        if let user = is_login(req: request) {
            if let username = user["username"] as? String,username != "", let userid = user["userid"] as? Int ,userid != 0 {
                islogin = true
            }
            
            //域对象  PageHandlers处理
            request.scratchPad["locals"] = [
                    "login":islogin
                    ,"username":user["username"] ?? ""
                    ,"userid":user["userid"] ?? 0
                    ,"userpic":user["userpic"] ?? ""
                    ,"is_verify":user["is_verify"] ?? ""
                    ,"email":user["email"] ?? ""
                    ,"create_time":user["create_time"] ?? ""
            ]
        }
        
        if in_white_list {
            callback(.continue(request, response))
        }else{
            if islogin {
                request.session!.data.updateValue(true, forKey: "login")
                callback(.continue(request, response))
            }else{
                if let st = request.header(.accept){
                    //如果是接口请求
                    if st.components(separatedBy: "application/json").count > 1  {
                        callback(.execute(request, response))
                        do{
                            try response.setBody(json: ["success":false,"msg":"该操作需要先登录"])
                            response.completed()
                        }catch{
                            Log.error(message: "\(error)")
                        }
                    }else{
                        response.redirect(path: "/login")
                    }
                }
            }
        }
    }
}


