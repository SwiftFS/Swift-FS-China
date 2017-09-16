//
//  upload.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/31.
//
//

import Foundation
import PerfectHTTP
import PerfectLib

class Upload {
    
    static func avatar(data:[String:Any]) throws -> RequestHandler{
        return {
            req,res in
            do{
                let session_user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                guard let user_id = session_user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"上传之前请先登录."])
                    res.completed()
                    return
                }
                guard let uploads = req.postFileUploads, uploads.count > 0,uploads.count == 1 else{
                    try res.setBody(json: ["success":false,"msg":"请选择正确的图片数量"])
                    res.completed()
                    return
                }
                let fileDir = Dir(Dir.workingDir.path + "webroot/avatar")
                do {
                    try fileDir.create()
                } catch {
                    Log.error(message: "\(error)")
                }
                
                let upload = uploads[0]
                
                
                let thisFile = File(upload.tmpFileName)
                let date = NSDate()
                let timeInterval = date.timeIntervalSince1970
                let hashName = "\(timeInterval.hashValue)"
                
                var type:String?
                let typeArray = upload.contentType.components(separatedBy: "/")
                guard typeArray.count >= 2 else {
                    try res.setBody(json: ["success":false,"msg":"获取类型出错"])
                    res.completed()
                    return
                }
                type = typeArray[1]
                let picName = hashName + "." + type!
                let _ = try thisFile.moveTo(path: fileDir.path + picName, overWrite: true)
                let judge =  try UserServer.update_avatar(avatar: picName, userid: user_id)
                guard judge != false else {
                    try res.setBody(json: ["success":false,"msg":"上传失败"])
                    res.completed()
                    return
                }
                
                try res.setBody(json: ["success":true,"originFilename":upload.tmpFileName,"filename":picName])
                res.completed()
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }
    
    static func file(data:[String:Any]) throws -> RequestHandler{
        return {
            req,res in
            do{
                let session_user:[String:Any]? = req.session?.data["user"] as? [String : Any]
                guard let user_id = session_user?["userid"] as? Int else {
                    try res.setBody(json: ["success":false,"msg":"上传之前请先登录."])
                    res.completed()
                    return
                }
                
                guard let uploads = req.postFileUploads, uploads.count > 0,uploads.count == 1 else{
                    try res.setBody(json: ["success":false,"msg":"请选择正确的图片数量"])
                    res.completed()
                    return
                }
                let fileDir = Dir(Dir.workingDir.path + "webroot/avatar")
                do {
                    try fileDir.create()
                } catch {
                    Log.error(message: "user_id:\(user_id),\(error)")
                }
                
                let upload = uploads[0]
                
                let thisFile = File(upload.tmpFileName)
                let date = NSDate()
                let timeInterval = date.timeIntervalSince1970
                let hashName = "\(timeInterval.hashValue)"
                
                var type:String?
                let typeArray = upload.contentType.components(separatedBy: "/")
                guard typeArray.count >= 2 else {
                    try res.setBody(json: ["success":false,"msg":"获取类型出错"])
                    res.completed()
                    return
                }
                type = typeArray[1]
                let picName = hashName + "." + type!
                let file = try thisFile.moveTo(path: fileDir.path + picName, overWrite: true)
                let tempPicPath = "/" + picName
                
                guard file.exists != false else {
                    try res.setBody(json: ["success":false,"msg":"上传错误"])
                    res.completed()
                    return
                }
                
                
                try res.setBody(json: ["success":true,"originFilename":tempPicPath,"filename":picName])
                res.completed()
            }catch{
                Log.error(message: "\(error)")
            }
        }
    }


}
