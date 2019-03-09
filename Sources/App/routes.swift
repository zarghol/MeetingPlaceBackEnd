import Vapor
import Crypto
import Authentication

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }

    let userController = UserController()

    router.get("users", use: userController.allUsernames)

    let userRoute = router.grouped("user")
    userRoute.post(use: userController.create)

    let basicAuth = User.basicAuthMiddleware(using: BCryptDigest())
    let tokenManagementRoute = userRoute.grouped("token").grouped(basicAuth)

    tokenManagementRoute.post(use: userController.createToken)
    tokenManagementRoute.get(use: userController.allTokens)
    tokenManagementRoute.delete(use: userController.deleteToken)

    let tokenAuth = User.tokenAuthMiddleware()
    userRoute.grouped(tokenAuth).delete(use: userController.delete)

    let guardAuth = User.guardAuthMiddleware()
    let unprotectedMeetingRoute = router.grouped("meeting")
    let meetingProtectedRoute = unprotectedMeetingRoute.grouped([tokenAuth, guardAuth])
    let meetingController = MeetingController()

    meetingProtectedRoute.post(use: meetingController.create())
    meetingProtectedRoute.put(Int.parameter, use: meetingController.edit)
    meetingProtectedRoute.get(use: meetingController.mine)
    meetingProtectedRoute.delete(Int.parameter, use: meetingController.delete)

    unprotectedMeetingRoute.get("all", use: meetingController.all)
    unprotectedMeetingRoute.get("day", String.parameter, use: meetingController.oneDay)
    unprotectedMeetingRoute.get(Int.parameter, use: meetingController.one)
    
    
}
