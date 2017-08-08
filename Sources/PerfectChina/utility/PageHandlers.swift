//
//  PageHandlers.swift
//  Perfect-App-Template
//
//  Created by Jonathan Guthrie on 2017-02-20.
//	Copyright (C) 2017 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//


import PerfectHTTP
import Foundation
import PerfectLib
import Stencil


//public struct MustacheHandler: MustachePageHandler {
//	var context: [String: Any]
//	public func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
//		contxt.extendValues(with: context)
//		do {
//			contxt.webResponse.setHeader(.contentType, value: "text/html")
//			try contxt.requestCompleted(withCollector: collector)
//		} catch {
//			let response = contxt.webResponse
//			response.status = .internalServerError
//			response.appendBody(string: "\(error)")
//			response.completed()
//		}
//	}
//
//	public init(context: [String: Any] = [String: Any]()) {
//		self.context = context
//	}
//}
//
//
//
//
//extension HTTPResponse {
//    
//    func jsonforarr(arr:[Any],json:JSONConvertible,skipContentType: Bool = false)  throws -> HTTPResponse {
//        
//        let applicationJson = "application/json"
//        let string = try json.jsonEncodedString()
//        if !skipContentType {
//            setHeader(.contentType, value: applicationJson)
//        }
//        return setBody(string: string)
//    }
//    
//    public func render2(template: String, context: [String: Any] = [String: Any]()) {
// 
//        mustacheRequest(request: self.request, response: self, handler: MustacheHandler(context: context), templatePath: request.documentRoot + "/\(template).mustache")
//        
//	}
//}

extension HTTPResponse {
    public func render(template: String, context: [String: Any] = [String: Any]()) {
        //设置路径
        let fsLoader = FileSystemLoader(paths: ["webroot/views"])
        let environment = Environment(loader: fsLoader)
        
        var context = context
        var dic:[String:Any] = [:]
        let local = request.scratchPad["locals"] as? [String:Any]
        
        if local != nil && (local!["login"] != nil) && (local!["userid"] != nil) && (local!["username"] != nil) && (local!["username"] != nil) && (local!["login"] != nil){
        }
        
        dic["login"] = false
        dic["username"] = local?["username"] ?? ""
        dic["userid"] = local?["userid"] ?? 0
        dic["create_time"] = local?["create_time"] ?? ""
        let isLogin = local?["login"] as? Bool
        if isLogin != nil && isLogin! == true{
            dic["login"] = true
        }
        
        context["locals"] = dic
        do{
            let stencil = try environment.renderTemplate(name: "\(template)"+".html", context: context)
            self.setBody(string: stencil)
            self.completed()
        }catch{
            Log.error(message: "\(error)")
        }
        
    }
    //重定向
    public func redirect(path: String) {
        self.status = .found
        self.addHeader(.location, value: path)
        self.completed()
    }

}


