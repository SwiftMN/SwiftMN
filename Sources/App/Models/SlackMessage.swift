//
//  SlackMessage.swift
//  App
//
//  Created by Steven Vlaminck on 10/24/17.
//
import Vapor

enum SlackMessageType: String {
    case ephemeral
    case inChannel = "in_channel"
}

protocol SlackMessage {
    var text: String { get }
    var attachments: [MessageAttachment] { get }
    var responseType: SlackMessageType { get }
}

extension SlackMessage where Self: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("response_type", responseType.rawValue)
        try json.set("text", text)
        try json.set("attachments", attachments)
        return json
    }
}

protocol MessageAttachment {
    
    var fallback: String { get }
    var title: String { get }
    var title_link: String { get }
    
    var author_name: String? { get }
    var author_icon: String? { get }
    var footer: String? { get }
    var footer_icon: String? { get }
    var color: String? { get }
}

extension MessageAttachment where Self: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("fallback", fallback)
        try json.set("title", title)
        try json.set("title_link", title_link)
        if let author_name = author_name {
            try json.set("author_name", author_name)
        }
        if let author_icon = author_icon {
            try json.set("author_icon", author_icon)
        }
        if let footer = footer {
            try json.set("footer", footer)
        }
        if let footer_icon = footer_icon {
            try json.set("footer_icon", footer_icon)
        }
        if let color = color {
            try json.set("color", color)
        }
        return json
    }
}
