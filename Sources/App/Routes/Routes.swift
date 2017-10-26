import Vapor

extension Droplet {
    func setupRoutes() throws {
        guard let verificationToken = config["slack", "token"]?.string else {
            // If you're running locally, make sure the file /Config/secrets/slack.json exists
            // /Config/slack.json is set up to use a `vapor cloud config` which is not available locally
            // If vapor cloud deploy is failing, make sure you have a `vapor cloud config` set up
            // `vapor cloud config modify SLACK_TOKEN=<slack_token>`
            throw Abort(.internalServerError, reason: "Startup failed due to missing Slack token")
        }
        let slackCommandValidator = SlackCommandValidator(verificationToken: verificationToken)

        /// Hello World
        get { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        /// REST endpoints for Talks
        try resource("talks", TalkController.self)

        /// Slack Slash Commands
        grouped(slackCommandValidator).group("slashCommand") { route in
            let slackController = SlackController()
            route.post("list_talks", handler: slackController.listTalks)
            route.post("suggest_talk", handler: slackController.suggestTalk)
        }
    }
}
