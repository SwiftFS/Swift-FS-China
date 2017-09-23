//
//  Configation.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/26.
//
//

let banner = "asd"

struct page_config {
    static let index_topic_page_size = 10 //-- 首页每页文章数
    static let topic_comment_page_size = 20// -- 文章详情页每页评论数
    static let notification_page_size = 10 // -- 通知每页个数
}

let notification_page_size = 10

//白名单
let whitelist = [
    "^/m1",
    "^/m2",
    "^/index$",
    "^/ask$",
    "^/wiki$",
    "^/wiki/$",
    "^/wiki/[0-9a-zA-Z-_]+",
    "^/share$",
    "^/category/[0-9]+$",
    "^/topics/all$",
    "^/topic/[0-9]+/view$",
    "^/topic/[0-9]+/query$",
    "^/comments/all$",
    "^/user/[0-9a-zA-Z-_]+/index$",
    "^/user/[0-9a-zA-z-_]+/topics$",
    "^/user/[0-9a-zA-z-_]+/collects$",
    "^/user/[0-9a-zA-z-_]+/comments$",
    "^/user/[0-9a-zA-z-_]+/follows$",
    "^/user/[0-9a-zA-z-_]+/fans$",
    "^/user/[0-9a-zA-z-_]+/hot_topics$",
    "^/user/[0-9a-zA-z-_]+/like_topics$",
    "^/verification/",
    "^/login$",
    "^/email-verification",
    "^/auth/sign_up$",
    "^/about$",
    "^/to/github$",
    "^/register$",
    "^/auth/response/github",
    "^/error/$",
    "^/search/$",
]


#if os(Linux)
    struct ApplicationConfiguration {
        let baseURL =  "https://swiftfs.org"
        let baseDomain = "localhost"
        let mysqldbname  = "blog"
        let mysqlhost = "127.0.0.1"
        let mysqlport = 3306
        let mysqlpwd = ""
        let mysqluser =  "root"
        let httpport =  8181
        let pwd_secret = "xxxxxxxxxxxxxxxx" //-- 用于存储密码的盐, 16位数
        
        //重定向
        let endpointAfterAuth = "https://www.swiftfs.org/auth/response/github"
        let redirectAfterAuth = "https://www.swiftfs.org/register"
        
        let appid = "xxx"
        let secret = "xxx"
    }
    
#else
    struct ApplicationConfiguration {
        let baseURL =  "http://localhost:8181"
        let baseDomain = "localhost"
        let mysqldbname  = "blog"
        let mysqlhost = "127.0.0.1"
        let mysqlport = 3306
        let mysqlpwd = ""
        let mysqluser =  "root"
        let httpport =  8181
        let pwd_secret = "xxxxxxxxxxxxxxxx" //-- 用于存储密码的盐 16位数
        
        //重定
        let endpointAfterAuth = "http://localhost:8181/auth/response/github"
        let redirectAfterAuth = "http://localhost:8181/register"
        
        let appid = "xxx"
        let secret = "xxx"
    }
#endif


struct STMPConfig{
    //stmp
    public static let url = "smtp://smtp.ym.163.com"
    
    public static let username = "mubin@swiftfs.org"
    
    public static let password = "xxxxxx"
}






