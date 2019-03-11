import Vapor
import Crypto
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }

    // User routes
    let userController = UserController()

    router.get("users", use: userController.allUsernames)

    let userRoute = router.grouped("user")
    userRoute.post(use: userController.create)

    let basicAuth = User.basicAuthMiddleware(using: BCryptDigest())
    let tokenManagementRoute = userRoute.grouped("token").grouped(basicAuth)

    tokenManagementRoute.post(use: userController.createToken)
    tokenManagementRoute.get(use: userController.allTokens)
    tokenManagementRoute.delete(String.parameter, use: userController.deleteToken)

    let tokenAuth = User.tokenAuthMiddleware()
    userRoute.grouped(tokenAuth).delete(use: userController.delete)

    let unprotectedTalkRoute = router.grouped("talk")
    let guardAuth = User.guardAuthMiddleware()
    let talkProtectedRoute = unprotectedTalkRoute.grouped([tokenAuth, guardAuth])

    // Talk routes
    let talkController = TalkController()

    talkProtectedRoute.post(use: talkController.create())
    talkProtectedRoute.put(Int.parameter, use: talkController.edit)
    talkProtectedRoute.get(use: talkController.mine)
    talkProtectedRoute.delete(Int.parameter, use: talkController.delete)

    unprotectedTalkRoute.get("all", use: talkController.all)
    unprotectedTalkRoute.get("day", String.parameter, use: talkController.oneDay)
    unprotectedTalkRoute.get(Int.parameter, use: talkController.one)
}
