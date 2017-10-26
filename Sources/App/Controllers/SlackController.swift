//
//  SlackController.swift
//  App
//
//  Created by Steven Vlaminck on 10/25/17.
//

import Vapor
import HTTP

final class SlackController {
    
    private func respond(to request: Request, with body: BodyRepresentable? = nil) throws -> HTTP.Response {
        let responseUrl = try request.responseUrl()
        return try EngineClient.factory.post(
            responseUrl,
            query: [:],
            [HeaderKey.contentType: "application/json"],
            body
        )
    }
    
    func listTalks(_ request: Request) throws -> ResponseRepresentable {

        let talks = try Talk.all()
        let message = try ListTalksMessage(talks: talks).makeJSON()

        background {
            let _ = try? self.respond(to: request, with: message)
        }

        return "Hang tight while I fetch those for you."
    }
    
    func suggestTalk(_ req: Request) throws -> ResponseRepresentable {
        let text = try req.text()
        let talk = Talk(content: text)
        try talk.save()
        return "I've added \(text) to the list of suggested talks"
    }
}

private extension Request {
    /// Pull response_url from the formURLEncoded body
    /// return BadRequest error if missing
    func responseUrl() throws -> String {
        guard
            let data = formURLEncoded,
            let responseUrl = data["response_url"]?.string
        else {
            throw Abort(.badRequest, reason: "Missing response_url")
        }
        return responseUrl
    }
    
    /// Pull text from the formURLEncoded body
    /// return BadRequest error if missing
    func text() throws -> String {
        guard
            let data = formURLEncoded,
            let text = data["text"]?.string
        else {
            throw Abort(.badRequest, reason: "Missing text")
        }
        return text
    }
}
