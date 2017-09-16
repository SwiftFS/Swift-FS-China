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
        dic["userpic"] = local?["userpic"] ?? ""
        dic["create_time"] = local?["create_time"] ?? ""
        dic["email"] = local?["email"] ?? ""
        dic["is_verify"] = local?["is_verify"] ?? ""
        
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


