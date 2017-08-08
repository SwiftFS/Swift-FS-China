//
//  Utility.swift
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

import BCrypt

// Base class that is then extended by individual helper functions
public class Utility {
    //bcrypt
    static func encode(message:String) -> String? {
        let secret:String! = pwd_secret
        do{
            let sail = try Salt.init(bytes: secret.bytes)
            let digest = try BCrypt.Hash.make(message: message, with: sail)
            return digest.makeString()
        }catch{
            return nil
        }
    }
    
    static func unencode(message:String) -> Bool? {

        do{
            let result = try BCrypt.Hash.verify(message: "foo", matches: message)
            return result
        }catch{
            return nil
        }
    }
}
