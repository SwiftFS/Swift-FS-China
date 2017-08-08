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
public  func CheckLogin(data: [String:Any]) throws -> HTTPRequestFilter {
    
    return checklogin()
}


struct checklogin:HTTPRequestFilter {
    
    func is_login(req:HTTPRequest) -> [String:Any]? {
        
        guard req.session != nil else {
            return nil
        }
        

        guard let user:[String:Any] = req.session!.data["user"] as? [String : Any]  else{
            
            return nil
        }
        
        return user
    }
    
    func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
        guard let st = request.header(HTTPRequestHeader.Name.accept) else{
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
        if requestPath == "//" {
            in_white_list = true
        }else{
            for address in whitelist{
                if address.components(separatedBy: requestPath).count > 1
                {
                   in_white_list = true
                    break
                }
            }
        }
        
        //判断是否登录
        let user = is_login(req: request)
        if (user != nil) {
            if user?["username"] != nil && user?["userid"] != nil && (user!["username"] as? String != "") && (user!["userid"] as? Int != 0){
                islogin = true
            }
        }
        
        //域对象  PageHandlers处理
        let dic:[String:Any] = [ "login":islogin
                                ,"username":user?["username"] ?? ""
                                ,"userid":user?["userid"] ?? 0
                                ,"create_time":user?["create_time"] ?? ""]
        if in_white_list {
            request.scratchPad["locals"] = dic
            callback(.continue(request, response))
        }else{
            if islogin {
                request.scratchPad["locals"] = dic
                request.session!.data.updateValue(true, forKey: "login")
                callback(.continue(request, response))
            }else{
                if let st = request.header(HTTPRequestHeader.Name.accept){
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


