//
//  Talk.swift
//  App
//
//  Created by Steven Vlaminck on 10/25/17.
//

import Vapor
import FluentProvider
import HTTP

final class Talk: Model {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of the Talk
    var content: String
    
    /// The column names for `id` and `content` in the database
    struct Keys {
        static let id = "id"
        static let content = "content"
    }
    
    /// Creates a new Talk
    init(content: String) {
        self.content = content
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Talk from the
    /// database row
    init(row: Row) throws {
        content = try row.get(Talk.Keys.content)
    }
    
    // Serializes the Talk to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Talk.Keys.content, content)
        return row
    }
}

// MARK: Fluent Preparation

extension Talk: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Talks
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Talk.Keys.content)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Talk (POST /talks)
//     - Fetching a talk (GET /talks, GET /talks/:id)
//
extension Talk: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            content: try json.get(Talk.Keys.content)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Talk.Keys.id, id)
        try json.set(Talk.Keys.content, content)
        return json
    }
}

// MARK: HTTP

// This allows Talk models to be returned
// directly in route closures
extension Talk: ResponseRepresentable { }

// MARK: Update

// This allows the Talk model to be updated
// dynamically by the request.
extension Talk: Updateable {
    // Updateable keys are called when `talk.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Talk>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Talk.Keys.content, String.self) { talk, content in
                talk.content = content
            }
        ]
    }
}
