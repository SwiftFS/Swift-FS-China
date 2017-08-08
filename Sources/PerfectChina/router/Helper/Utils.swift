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
    
    class func days_after_registry(req:HTTPRequest) {
        _ = 0
        _ = 0
        
        if req.session != nil {
            let user:[String:Any] = req.session?.data["user"] as! [String : Any]
            let create_time = user["create_time"] as? Date
            if create_time != nil {
                let now = Utils.now()
                let dateComponentsFormatter = DateComponentsFormatter()
                dateComponentsFormatter.allowedUnits = .day
                
                let autoFormattedDifference = dateComponentsFormatter.string(from: create_time!, to: now)
                
                Log.info(message: "\(String(describing: autoFormattedDifference!.int))", evenIdents: true)
                
//                a = now.timeIntervalSince(create_time!)
                
            }
        }
    }
    
    
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
