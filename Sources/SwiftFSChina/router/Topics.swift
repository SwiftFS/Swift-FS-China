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



class Topics {
    //所有文章
    static func topics(data: [String:Any]) throws -> RequestHandler {

        return {
            request, response in
            do{
                
            let page_no = request.param(name: "page_no")?.int ?? 1
            let topic_type = request.param(name: "type") ?? "default"
            let category = request.param(name: "category") ?? "0"
            let page_size = page_config.index_topic_page_size
            var total_count = 0
            
            total_count = try TopicServer.get_total_count(topic_type: topic_type, category: category)
         
            let total_page = Utils.total_page(total_count: total_count, page_size: page_size)
            
            let topics = TopicServer.get_all(topic_type: topic_type, category: category, page_no: page_no, page_size: page_size)
                
            if topics == nil {
                try response.setBody(json: ["success":false])
                response.completed()
                return
            }
                
            
                
            let encoded = try? encoder.encode(topics)
                
            if encoded != nil {
                if let json = String(data: encoded!,encoding:.utf8){
                    if let decoded = try json.jsonDecode() as? [[String:Any]] {
                        let dic:[String:Any] = ["totalCount":total_count,"totalPage":total_page,"currentPage":page_no,"topics":decoded]
                        try response.setBody(json: ["success":true,"data":dic])
                    }
                }
            }
            
            response.completed()
                
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
}
