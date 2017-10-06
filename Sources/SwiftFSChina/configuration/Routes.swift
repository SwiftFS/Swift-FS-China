//
//  Routes.swift
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

import PerfectHTTPServer
import PerfectLib
import PerfectHTTP
import OAuth2

func mainRoutes() -> [[String: Any]] {
    
    let dic = ApplicationConfiguration()
    
    GitHubConfig.appid = dic.appid
    GitHubConfig.secret = dic.secret
    
    GitHubConfig.endpointAfterAuth = dic.endpointAfterAuth
    GitHubConfig.redirectAfterAuth = dic.redirectAfterAuth
    

	var routes: [[String: Any]] = [[String: Any]]()

	routes.append(["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
	               "documentRoot":"./webroot",
	               "allowRequestFilter":false,
	               "allowResponseFilters":true])
	
    //github
    routes.append(["method":"get", "uri":"/to/github", "handler":OAuth.sendToProvider])
    //
    routes.append(["method":"get", "uri":"/auth/response/github", "handler":OAuth.authResponse])

    
	//Handler for home page
	routes.append(["method":"get", "uri":"/", "handler":Handlers.index])
    routes.append(["method":"get", "uri":"/index", "handler":Handlers.index])
    routes.append(["method":"get", "uri":"/share", "handler":Handlers.share])
    routes.append(["method":"get", "uri":"/ask", "handler":Handlers.ask])
    routes.append(["method":"get", "uri":"/settings", "handler":Handlers.settings])
	routes.append(["method":"get", "uri":"/about", "handler":Handlers.about])
	routes.append(["method":"get", "uri":"/login", "handler":Handlers.login])
	routes.append(["method":"get", "uri":"/register", "handler":Handlers.register])
    routes.append(["method":"get", "uri":"/notification/**", "handler":Notification.index])
    
    //wiki
    routes.append(["method":"get", "uri":"/wiki/{path}", "handler":Wiki.index])
    routes.append(["method":"get", "uri":"/wiki", "handler":Wiki.index])
    routes.append(["method":"get", "uri":"/wiki/", "handler":Wiki.index])
    //wiki-api
    routes.append(["method":"post", "uri":"/wiki/new", "handler":Wiki.newWiki])
    
    
    //user
    routes.append(["method":"get", "uri":"/user/{username}/index", "handler":User.index])
    routes.append(["method":"get", "uri":"/user/{username}/hot_topics", "handler":User.hotTopics])
    routes.append(["method":"get", "uri":"/user/{username}/like_topics", "handler":User.likeTopics])
    routes.append(["method":"get", "uri":"/user/{username}/topics", "handler":User.topics])
    routes.append(["method":"get", "uri":"/user/{username}/comments", "handler":User.comments])
    routes.append(["method":"get", "uri":"/user/{username}/collects", "handler":User.collects])
    routes.append(["method":"get", "uri":"/user/{username}/follows", "handler":User.follows])
    routes.append(["method":"post", "uri":"/user/follow", "handler":User.follow])
    routes.append(["method":"post", "uri":"/user/cancel_follow", "handler":User.cancelFollow])
    routes.append(["method":"get", "uri":"/user/{username}/fans", "handler":User.fans])
    routes.append(["method":"post", "uri":"/user/edit", "handler":User.edit])
    routes.append(["method":"post", "uri":"/user/change_pwd", "handler":User.changePwd])
    
    
    //notification
    routes.append(["method":"get", "uri":"/notification/all", "handler":Notification.requiredDate])
    
    //topic
    routes.append(["method":"get", "uri":"topic/{topic_id}/view", "handler":Topic.get])
    routes.append(["method":"get", "uri":"topic/new", "handler":Topic.new])
    routes.append(["method":"post", "uri":"topic/new", "handler":Topic.newTopic])
    routes.append(["method":"post", "uri":"topic/edit", "handler":Topic.edit])
    routes.append(["method":"get", "uri":"topic/{topic_id}/query", "handler":Topic.getQuery])
    
    routes.append(["method":"get", "uri":"topic/{topic_id}/edit", "handler":Topic.editTopic])
    routes.append(["method":"get", "uri":"topic/{topic_id}/delete", "handler":Topic.deleteTopic])
    routes.append(["method":"post", "uri":"topic/collect", "handler":Topic.collect])
    routes.append(["method":"post", "uri":"topic/like", "handler":Topic.like])
    routes.append(["method":"get", "uri":"topic/cancel_like", "handler":Topic.cancleLike])
    routes.append(["method":"post", "uri":"topic/cancel_collect", "handler":Topic.cancelCollect])
    
    //comments
    routes.append(["method":"get", "uri":"comments/all", "handler":Comments.getComments])
    routes.append(["method":"post", "uri":"comment/new", "handler":Comments.newComment])
    routes.append(["method":"get", "uri":"comment/{comment_id}/delete", "handler":Comments.delete])
    
    //auth
    routes.append(["method":"post", "uri":"/auth/sign_up", "handler":Auth.signUp])
    routes.append(["method":"post", "uri":"/auth/login", "handler":Auth.login])
    routes.append(["method":"get", "uri":"/auth/logout", "handler":Auth.logout])
    
    routes.append(["method":"get", "uri":"/topics/all", "handler":Topics.topics])
    
    //upload
    routes.append(["method":"post", "uri":"/upload/avatar", "handler":Upload.avatar])
    routes.append(["method":"post", "uri":"/upload/file", "handler":Upload.file])
    
    //notification
    routes.append(["method":"post", "uri":"notification/delete_all", "handler":Notification.deleteAll])
    routes.append(["method":"post", "uri":"notification/mark", "handler":Notification.mark])
    routes.append(["method":"post", "uri":"notification/{id}/delete", "handler":Notification.delete])
    
    //search
    routes.append(["method":"get", "uri":"search/*", "handler":Search.query])
    
    //email
    routes.append(["method":"get", "uri":"verification/{secret}", "handler":EmailAuth.verification])
    routes.append(["method":"get", "uri":"email-verification", "handler":EmailAuth.emailVerification])
    
    routes.append(["method":"post", "uri":"send-verification-mail", "handler":EmailAuth.sendVerificationMail])
    
    
	return routes
}
