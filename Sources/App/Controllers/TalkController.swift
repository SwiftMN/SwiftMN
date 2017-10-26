//
//  TalkController.swift
//  App
//
//  Created by Steven Vlaminck on 10/24/17.
//


import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Talks table
final class TalkController: ResourceRepresentable {
    /// When users call 'GET' on '/talks'
    /// it should return an index of all available talks
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Talk.all().makeJSON()
    }
    
    /// When consumers call 'POST' on '/talks' with valid JSON
    /// construct and save the talk
    func store(_ req: Request) throws -> ResponseRepresentable {
        let talk = try req.talk()
        try talk.save()
        return talk
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/talks/13rd88' we should show that specific talk
    func show(_ req: Request, talk: Talk) throws -> ResponseRepresentable {
        return talk
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'talks/l2jd9' we should remove that resource from the database
    func delete(_ req: Request, talk: Talk) throws -> ResponseRepresentable {
        try talk.delete()
        return Response(status: .ok)
    }
    
    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/talks' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Talk.makeQuery().delete()
        return Response(status: .ok)
    }
    
    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request, talk: Talk) throws -> ResponseRepresentable {
        // See `extension Talk: Updateable`
        try talk.update(for: req)
        
        // Save an return the updated talk.
        try talk.save()
        return talk
    }
    
    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Talk with the same ID.
    func replace(_ req: Request, talk: Talk) throws -> ResponseRepresentable {
        // First attempt to create a new Talk from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.talk()
        
        // Update the talk with all of the properties from
        // the new talk
        talk.content = new.content
        try talk.save()
        
        // Return the updated talk
        return talk
    }
    
    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Talk> {
        return Resource(
            index: index,
            store: store,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    /// Create a talk from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func talk() throws -> Talk {
        guard let json = json else { throw Abort.badRequest }
        return try Talk(json: json)
    }
}

/// Since TalkController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension TalkController: EmptyInitializable { }
