import FluentMySQL
import Vapor
import Authentication
import Crypto

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)


    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
//    middlewares.use(GuardAuthenticationMiddleware.self) // for all creation of meeting
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(ConnectionCloseMiddleware())
    services.register(middlewares)

    guard let hostname = Environment.get("hostname"),
        let portString = Environment.get("port"),
        let port = Int(portString),
        let username = Environment.get("username"),
        let password = Environment.get("password"),
        let database = Environment.get("database") else { throw Abort(.internalServerError) }

    let mysqlConfig = MySQLDatabaseConfig(hostname: hostname, port: port, username: username, password: password, database: database)

    // Configure a MySQL database

    let mysql = MySQLDatabase(config: mysqlConfig)

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: UserToken.self, database: .mysql)
    migrations.add(model: Talk.self, database: .mysql)
    migrations.add(migration: PermissionsMigration.self, database: .mysql)
    if env == .development {
        migrations.add(migration: DevelopmentDataMigration.self, database: .mysql)
    }

    services.register(migrations)
}
