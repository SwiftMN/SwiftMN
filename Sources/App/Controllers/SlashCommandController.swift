//
//  SlashCommandController.swift
//  App
//
//  Created by Steven Vlaminck on 10/25/17.
//

import Vapor
import HTTP

final class SlashCommandController {
    
    private func respond(to request: Request, with body: BodyRepresentable? = nil) throws -> HTTP.Response {
        let responseUrl = try request.formValue(key: .responseUrl)
        return try EngineClient.factory.post(
            responseUrl,
            query: [:],
            [HeaderKey.contentType: "application/json"],
            body
        )
    }
    
    func listTalks(_ request: Request) throws -> ResponseRepresentable {
        let talks = try Talk.all()
        guard talks.count > 0 else {
            return "No talks have been suggested.\nSuggest one with `/suggest_talk [talk idea]`"
        }

        let talkText = "Suggested talks:\n>>> - " + talks.map { $0.content }.joined(separator: "\n- ")
        let message = try SlackMessage(text: talkText).makeJSON()
        background {
            let _ = try? self.respond(to: request, with: message)
        }
        return "Hang tight while I fetch those for you."
    }
    
    func suggestTalk(_ request: Request) throws -> ResponseRepresentable {
        let text = try request.formValue(key: .text)
        let talk = Talk(content: text)
        try talk.save()
        return "I've added \(text) to the list of suggested talks"
    }
}
