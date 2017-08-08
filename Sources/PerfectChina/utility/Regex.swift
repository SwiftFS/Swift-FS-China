//
//  MyRegex.swift
//  PerfectChina
//
//  Created by mubin on 2017/7/26.
//
//

import Foundation

import Foundation

struct Regex {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {
        regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    
    func match(input: String) -> Bool {
        if let matches = regex?.matches(in: input,
                                                options: [],
                                                range: NSMakeRange(0, (NSString(string:input)).length)) {
            return matches.count > 0
        }
        else {
            return false
        }
    }
}

