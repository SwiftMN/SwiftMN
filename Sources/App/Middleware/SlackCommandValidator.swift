//
//  SlackCommandValidator.swift
//  App
//
//  Created by Steven Vlaminck on 10/24/17.
//

import HTTP

final class SlackCommandValidator: Middleware {
    
    private let verificationToken: String
    
    init(verificationToken: String) {
        self.verificationToken = verificationToken
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard let data = request.formURLEncoded, let token = data["token"]?.string else {
            throw Abort(.badRequest, reason: "Missing token")
        }
        
        if self.verificationToken != token {
            throw Abort(.unauthorized, reason: "Invalid token")
        }
        
        return try next.respond(to: request)
    }
}

