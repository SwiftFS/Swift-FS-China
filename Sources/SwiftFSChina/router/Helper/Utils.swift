//
//  utils.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/28.
//
//

import Foundation
import PerfectHTTP
import PerfectLib

class Utils {
    
 
    
    class func now() -> Date{
        
        return  Date()
    }
    
    class func string_split (str:String?,delimiter:String?) -> String?{
        if str == nil || str == "" || delimiter == nil{
            return nil
        }
        return nil   
    }
    
    class func total_page(total_count:Int,page_size:Int)->Int {
        var total_page = 0
        if total_count % page_size == 0 {
            total_page = total_count/page_size
        }else{
            let  tmp = total_count/page_size
            total_page = tmp + 1
        }
        return total_page
    }
    
    class func days_after_registry(req:HTTPRequest)->(Int,Int){
        let diff = 0
        let diff_days = 0
        var userjs:[String:Any]?
        if (req.session != nil) && (req.session!.data["user"] != nil){
            let user = req.session!.data["user"] as! [String:Any]
            userjs = user
        }
        if userjs != nil {
           _ = userjs!["create_time"]
            
        }
        
        return (diff,diff_days)
    }
}
