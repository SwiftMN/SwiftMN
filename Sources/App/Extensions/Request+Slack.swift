//
//  Request+Slack.swift
//  App
//
//  Created by Steven Vlaminck on 10/24/17.
//

import Foundation
import HTTP

extension Request {

    /// Pull the value for the given `key` from the formURLEncoded body
    /// return BadRequest error if missing
    func formValue(key: SlashCommandKey) throws -> String {
        return try formValue(string: key.rawValue)
    }
    
    /// Pull the value for the given `string` from the formURLEncoded body
    /// return BadRequest error if missing
    func formValue(string: String) throws -> String {
        guard
            let data = formURLEncoded,
            let value = data[string]?.string
        else {
            throw Abort(.badRequest, reason: "Missing value for key: \(string)")
        }
        return value
    }
}
