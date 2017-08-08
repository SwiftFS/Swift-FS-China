//
//  Filter404.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/25.
//
//
import PerfectHTTP

public  func Filter404(data: [String:Any]) throws -> HTTPResponseFilter {
    return Filter4042()
}


struct Filter4042: HTTPResponseFilter {
    func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        callback(.continue)
    }
    
    func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        
        if case .notFound = response.status {
            response.setBody(string: "文件 \(response.request.path) 不存在。")
            response.setHeader(.contentLength, value: "\(response.bodyBytes.count)")
            response.completed()
            callback(.done)
        } else {
            
            callback(.continue)
        }
    }
}

