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



var HTTPport = 8181

//配置 mysql 端口
config()


let server = HTTPServer()

// 配置输出文件
let httplogger = RequestLogger()
RequestLogFile.location = "./webLog.log"

//// 会话名称
// 这个名称也会成为浏览器cookie的名称
SessionConfig.name = "PerfectSession"
// 允许处于零活动连接的时间限制，单位是秒
// 86400 秒表示一天。
SessionConfig.idle = 1000
// 可选项，设置 Cookie作用域
//SessionConfig.cookieDomain = "localhost"
// 可选项，锁定创建时用的 IP 地址，即在会话过程中不允许 IP 地址发生变化，否则视为欺诈。默认为 false
SessionConfig.IPAddressLock = true
// 可选项，锁定创建时所用的用户代理，即服务器在会话过程中不允许用户代理发生变化，否则视为欺诈。默认为 false
SessionConfig.userAgentLock = true


// Configure Server
var confData: [String:[[String:Any]]] = [
	"servers": [
		[
			"name":"呱呱呱",
			"port":HTTPport,
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
    // Launch the servers based on the configuration data.
    try HTTPServer.launch(configurationData: confData)
    try server.start()

} catch {
    
    Log.info(message: "连接数据库成功")
    //    if same add port addone
    // fatal error launching one of the servers
}


