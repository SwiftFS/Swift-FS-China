//
//  Wiki.swift
//  PerfectChina
//
//  Created by mubin on 2017/9/7.
//
//

import Foundation
import PerfectHTTP
import PerfectLib

class Wiki{
    
    static func index(data: [String:Any]) throws -> RequestHandler {
        return {
            req, res in
            
            guard let currenPath = data["uri"] as? String else {
                
                return
            }
            do {
                //跳到默认页
                if currenPath == "/wiki/" || currenPath == "/wiki" {
                    try homePage(req: req, res: res)
                    return
                }
                
                let sonpath = req.urlVariables["path"]
                //新增
                if sonpath == "new" {
                    new(req: req, res: res)
                    return
                }
                
            }catch{
                Log.error(message: "\(error)")
            }
        
            
        }
    }
    
    static func homePage(req:HTTPRequest,res:HTTPResponse) throws{
        
        let wikis = try WikiServer.quert_recommends()
        let encoded = try? encoder.encode(wikis)
        if encoded != nil {
            if let json = encodeToString(data: encoded!){
                if let decoded = try json.jsonDecode() as? [[String:Any]] {
                    res.render(template: "wiki/wiki",context: ["recommends":decoded])
                }
            }
        }
        
    }
    
    //新增wiki
    static func new(req:HTTPRequest,res:HTTPResponse){
        res.render(template: "wiki/wiki_new")
    }
    
// MARK: ---------------------------- api ----------------------------
    static func newWiki(data: [String:Any]) throws -> RequestHandler {
        return {
            req,res in
            
            let title = req.param(name: "title")
            let content = req.param(name: "content")
            let urlPath = req.param(name: "url_path")
            let is_recommend = req.param(name: "is_recommend")
            
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
                
                guard title != nil && content != nil && content != "" && title != "" && is_recommend != "" && is_recommend?.int != nil else {
                    try res.setBody(json: ["success":false,"msg":"title and content should not be empty"])
                    res.completed()
                    return
                }
                
                let status = try WikiServer.new(title: title!, content: content!, user_id: user_id, user_name: user_name, is_recommend: is_recommend!.int!, url_path: urlPath!)
                
                guard status != nil else {
                    return
                }
//                todo---
                
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }

}
