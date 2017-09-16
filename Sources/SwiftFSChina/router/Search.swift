//
//  Search.swift
//  PerfectChina
//
//  Created by mubin on 2017/8/10.
//
//

import Foundation
import PerfectHTTP
import PerfectLib

class Search {
    
    static func query(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            do{
                guard  let q = request.param(name: "q") else {
                    response.render(template: "search")
                    return
                }
                let page_size = page_config.index_topic_page_size
                let page_no = request.param(name: "page_no")?.int ?? 1
                let total_count = try SearchServer.quert_cout(query: q)
                let total_page = Utils.total_page(total_count: total_count, page_size: page_size)
                
                let result_topic =  try SearchServer.query_by_topic(query:q)
                let result_user =  try SearchServer.query_by_user(query: q)
                
                let user_count = result_user.count
                let user_json = result_user.toJSON() as! [[String:Any]]
                let topic_json = result_topic.toJSONValue() as! [[String:Any]]
                
                let content:[String:Any] = ["total_count":total_count + user_count
                                            ,"q":q
                                            ,"useritems":user_json
                                            ,"topicitems":topic_json]
                
                
                response.render(template: "search/search", context: content)
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
}


private extension String {
    func positionOf(sub:String)->Int {
        var pos = -1
        if let range = range(of:sub) {
            if !range.isEmpty {
                pos = characters.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
}


