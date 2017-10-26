//
//  SlackController.swift
//  App
//
//  Created by Steven Vlaminck on 10/25/17.
//

import Vapor
import HTTP

final class SlackController {
    
    func listTalks(_ req: Request, client: ClientFactoryProtocol) throws -> ResponseRepresentable {

        let responseUrl = try req.responseUrl()
        let talks = try Talk.all()
        let message = try ListTalksMessage(talks: talks).makeJSON()
        
        background {
            let _ = try? client.post(responseUrl, query: [:], [HeaderKey.contentType: "application/json"], message)
        }

        return "Hang tight while I fetch those for you."
    }
    
    func suggestTalk(_ req: Request, client: ClientFactoryProtocol) throws -> ResponseRepresentable {
        let text = try req.text()
        let talk = Talk(content: text)
        try talk.save()
        return "I've added \(text) to the list of suggested talks"
    }
}

extension Request {
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
