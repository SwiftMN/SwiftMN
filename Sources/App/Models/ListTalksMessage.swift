//
//  ListTalksMessage.swift
//  App
//
//  Created by Steven Vlaminck on 10/25/17.
//

import Vapor

struct ListTalksMessage: SlackMessage, JSONRepresentable {
    
    let text: String
    let attachments: [MessageAttachment] = []
    let responseType: SlackMessageType
    
    init(talks: [Talk]) {
        if talks.count == 0 {
            self.text = "No talks have been suggested.\nSuggest one with `/suggest_talk [talk idea]`"
            self.responseType = .ephemeral
        } else {
            self.text = "Suggested talks:\n>>> - " + talks.map { $0.content }.joined(separator: "\n- ")
            self.responseType = .inChannel
        }
    }
}
