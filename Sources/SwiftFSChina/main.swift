//
//  main.swift
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

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectRequestLogger
import PerfectLogger

import PerfectSession



//连接数据库
connectionDatabase()

let server = HTTPServer()

// 配置输出文件
let httplogger = RequestLogger()
RequestLogFile.location = "./webLog.log"


// 这个名称也会成为浏览器cookie的名称
SessionConfig.name = "SwiftFSChina"
SessionConfig.idle = 3600
SessionConfig.IPAddressLock = true
SessionConfig.userAgentLock = true
SessionConfig.CSRF.checkState = true

let configuration = ApplicationConfiguration()

var confData: [String:[[String:Any]]] = [
	"servers": [
		[
			"name":"SwiftFS",
			"port":configuration.httpport,
			"routes":[],
			"filters":[]
		]
	]
]

// Load Filters
confData["servers"]?[0]["filters"] = filters()

// Load Routes
confData["servers"]?[0]["routes"] = mainRoutes()



do {
    try HTTPServer.launch(configurationData: confData)
    try server.start()

} catch {
    Log.error(message: "连接数据库成功")
}


