import Vapor

extension Droplet {
    func setupRoutes() throws {
        get { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        try resource("talks", TalkController.self)

    
        guard let verificationToken = config["slack", "token"]?.string else {
            throw Abort(.internalServerError, reason: "Unable to create SlackController")
        }
        let slackCommandValidator = SlackCommandValidator(verificationToken: verificationToken)
        
        grouped(slackCommandValidator).post("bot", "talks", "list") { req in
            return try SlackController().listTalks(req, client: self.client)
        }
        grouped(slackCommandValidator).post("bot", "talks", "suggest") { req in
            return try SlackController().suggestTalk(req, client: self.client)
        }

    }
}

