//
//  File.swift
//  
//
//  Created by lxthyme on 2023/9/8.
//

public enum User {
    case `default`
    case authenticated(username: String)

    public init(username: String) {
        self = .authenticated(username: username)
    }
}
