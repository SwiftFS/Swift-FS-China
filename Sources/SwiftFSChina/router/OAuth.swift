//
//  GitHub.swift
//	Perfect Authentication / Auth Providers
//  Inspired by Turnstile (Edward Jiang)
//
//  Created by Jonathan Guthrie on 2017-01-24
//
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

import Foundation
import PerfectHTTP
import PerfectSession
import OAuth2
import PerfectLib
import PerfectCURL
import cURL
import SwiftString


/// GitHub configuration singleton
public struct GitHubConfig {
    
    /// AppID obtained from registering app with GitHub (Also known as Client ID)
    public static var appid = ""
    
    /// Secret associated with AppID (also known as Client Secret)
    public static var secret = ""
    
    /// Where should Facebook redirect to after Authorization
    public static var endpointAfterAuth = ""
    
    /// Where should the app redirect to after Authorization & Token Exchange
    public static var redirectAfterAuth = ""
    
    public init(){}
}

/**
 GitHub allows you to authenticate against GitHub for login purposes.
 */
public class OAuth: OAuth2 {
    /**
     Create a GitHub object. Uses the Client ID and Client Secret obtained when registering the application.
     */
    public init(clientID: String, clientSecret: String) {
        let tokenURL = "https://github.com/login/oauth/access_token"
        let authorizationURL = "https://github.com/login/oauth/authorize"
        super.init(clientID: clientID, clientSecret: clientSecret, authorizationURL: authorizationURL, tokenURL: tokenURL)
    }
    
    
    private var appAccessToken: String {
        return clientID + "%7C" + clientSecret
    }
    
    
    /// After exchanging token, this function retrieves user information from GitHub
    public func getUserData(_ accessToken: String) -> [String: Any] {
        let url = "https://api.github.com/user?access_token=\(accessToken)"
        //		let (_, data, _, _) = makeRequest(.get, url)
        let data = makeRequest(.get, url)
        
        
        var out = [String: Any]()
        
        if let n = data["id"] {
            out["id"] = "\(n)"
        }
        if let n = data["email"] {
            out["email"] = "\(n)"
        }
        if let n = data["name"] {
            out["name"] = "\(n)"
        }
        if let n = data["login"] {
            out["login"] = "\(n)"
        }
        if let n = data["avatar_url"] {
            out["picture"] = n as! String
        }
        
        return out
    }
    
    /// GitHub-specific exchange function
    public func exchange(request: HTTPRequest, state: String) throws -> OAuth2Token {
        
        return try exchange(request: request, state: state, redirectURL: "\(GitHubConfig.endpointAfterAuth)?session=\((request.session?.token)!)")
    }
    
    /// GitHub-specific login link
    public func getLoginLink(state: String, request: HTTPRequest, scopes: [String] = []) -> String {
        return getLoginLink(redirectURL: "\(GitHubConfig.endpointAfterAuth)?session=\((request.session?.token)!)", state: state, scopes: scopes)
    }
    
    
    
    /// Route handler for managing the response from the OAuth provider
    /// Route definition would be in the form
    /// ["method":"get", "uri":"/auth/response/github", "handler":GitHub.authResponse]
    public static func authResponse(data: [String:Any]) throws -> RequestHandler {
        return {
            request, response in
            let fb = OAuth(clientID: GitHubConfig.appid, clientSecret: GitHubConfig.secret)
            do {
                
                guard let state = request.session?.data["csrf"] else {
                    throw OAuth2Error(code: .unsupportedResponseType)
                }
                
                let t = try fb.exchange(request: request, state: state as! String)
                
                request.session?.data["accessToken"] = t.accessToken
                request.session?.data["refreshToken"] = t.refreshToken
                
                let userdata = fb.getUserData(t.accessToken)
                
                request.session?.data["loginType"] = "github"
                
                
                guard let id = userdata["id"] as? String else{
                    Log.error(message: "获取失败")
                    return
                }
                
                //防空处理
                if let i:String = userdata["email"] as? String {
                    if i == "JSONConvertibleNull()" {
                        request.session?.data["email"] = ""
                    }else{
                        request.session?.data["email"] = i
                    }
                }
                
                
                if let i = userdata["id"] {
                    request.session?.data["id"] = i as! String
                }
                
                if let i:String = userdata["name"] as? String {
                    if i == "JSONConvertibleNull()" {
                        request.session?.data["name"] = ""
                    }else{
                        request.session?.data["name"] = i
                    }
                }
                
                if let i:String = userdata["login"] as? String {
                    if i == "JSONConvertibleNull()" {
                        request.session?.data["login"] = ""
                    }else{
                        request.session?.data["login"] = i
                    }
                }
                
                if let i = userdata["picture"] {
                    request.session?.data["picture"] = i as! String
                }
                
                let user = try UserServer.query_by_github_id(id: id.int!)
                
                guard user != nil else{
                    response.redirect(path: GitHubConfig.redirectAfterAuth, sessionid: (request.session?.token)!)
                    return
                }
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale.current //设置时区，时间为当前系统时间
                
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let ct = user!.create_time
                let stringDate = dateFormatter.string(from:ct!)
                
                let sessionDic:[String:Any] = ["username":user!.username,
                                               "userid":user!.id.id.id,
                                               "email":user!.email,
                                               "is_verify":user!.is_verify,
                                               "userpic":user!.avatar,
                                               "create_time":stringDate]
                request.session!.data.updateValue(sessionDic, forKey: "user")
                response.redirect(path: "/index", sessionid: (request.session?.token)!)
                
            } catch {
                Log.error(message: "\(error)")
            }
            
        }
    }
    
    
    
    
    
    /// Route handler for managing the sending of the user to the OAuth provider for approval/login
    /// Route definition would be in the form
    /// ["method":"get", "uri":"/to/github", "handler":GitHub.sendToProvider]
    public static func sendToProvider(data: [String:Any]) throws -> RequestHandler {
        //		let rand = URandom()
        
        return {
            request, response in
            // Add secure state token to session
            // We expect to get this back from the auth
            //			request.session?.data["state"] = rand.secureToken
            let tw = OAuth(clientID: GitHubConfig.appid, clientSecret: GitHubConfig.secret)
            response.redirect(path: tw.getLoginLink(state: request.session?.data["csrf"] as! String, request: request, scopes: ["user"]))
        }
    }
    
    
}


extension OAuth {
    
    
    /// The function that triggers the specific interaction with a remote server
    /// Parameters:
    /// - method: The HTTP Method enum, i.e. .get, .post
    /// - route: The route required
    /// - body: The JSON formatted sring to sent to the server
    /// Response:
    /// (HTTPResponseStatus, "data" - [String:Any], "raw response" - [String:Any], HTTPHeaderParser)
    func makeRequest(
        _ method: HTTPMethod,
        _ url: String,
        body: String = "",
        encoding: String = "JSON",
        bearerToken: String = ""
        //		) -> (Int, [String:Any], [String:Any], HTTPHeaderParser) {
        ) -> ([String:Any]) {
        
        let curlObject = CURL(url: url)
        curlObject.setOption(CURLOPT_HTTPHEADER, s: "Accept: application/json")
        curlObject.setOption(CURLOPT_HTTPHEADER, s: "Cache-Control: no-cache")
        curlObject.setOption(CURLOPT_USERAGENT, s: "PerfectAPI2.0")
        
        if !bearerToken.isEmpty {
            curlObject.setOption(CURLOPT_HTTPHEADER, s: "Authorization: Bearer \(bearerToken)")
        }
        
        switch method {
        case .post :
            let byteArray = [UInt8](body.utf8)
            curlObject.setOption(CURLOPT_POST, int: 1)
            curlObject.setOption(CURLOPT_POSTFIELDSIZE, int: byteArray.count)
            curlObject.setOption(CURLOPT_COPYPOSTFIELDS, v: UnsafeMutablePointer(mutating: byteArray))
            
            if encoding == "form" {
                curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/x-www-form-urlencoded")
            } else {
                curlObject.setOption(CURLOPT_HTTPHEADER, s: "Content-Type: application/json")
            }
            
        default: //.get :
            curlObject.setOption(CURLOPT_HTTPGET, int: 1)
        }
        
        
        var header = [UInt8]()
        var bodyIn = [UInt8]()
        
        var code = 0
        var data = [String: Any]()
        var raw = [String: Any]()
        
        var perf = curlObject.perform()
        defer { curlObject.close() }
        
        while perf.0 {
            if let h = perf.2 {
                header.append(contentsOf: h)
            }
            if let b = perf.3 {
                bodyIn.append(contentsOf: b)
            }
            perf = curlObject.perform()
        }
        if let h = perf.2 {
            header.append(contentsOf: h)
        }
        if let b = perf.3 {
            bodyIn.append(contentsOf: b)
        }
        let _ = perf.1
        
        // Parsing now:
        
        // assember the header from a binary byte array to a string
        //		let headerStr = String(bytes: header, encoding: String.Encoding.utf8)
        
        // parse the header
        //		let http = HTTPHeaderParser(header:headerStr!)
        
        // assamble the body from a binary byte array to a string
        let content = String(bytes:bodyIn, encoding:String.Encoding.utf8)
        
        // prepare the failsafe content.
        //		raw = ["status": http.status, "header": headerStr!, "body": content!]
        
        // parse the body data into a json convertible
        do {
            if (content?.characters.count)! > 0 {
                if (content?.startsWith("["))! {
                    let arr = try content?.jsonDecode() as! [Any]
                    data["response"] = arr
                } else {
                    data = try content?.jsonDecode() as! [String : Any]
                }
            }
            return data
            //			return (http.code, data, raw, http)
        } catch {
            return [:]
            //			return (http.code, [:], raw, http)
        }
    }
}

