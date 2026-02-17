import Foundation
import OSLog

// MARK: - Log Level

public enum LogLevel: String {
    case debug = "🔍 DEBUG"
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
    case critical = "🔥 CRITICAL"
}

// MARK: - Log Category

public enum LogCategory: String {
    case api = "API"
    case auth = "Auth"
    case data = "Data"
    case ui = "UI"
    case network = "Network"
    case storage = "Storage"
    case general = "General"
}

// MARK: - App Logger

public actor AppLogger {
    private let subsystem = "com.dxbconnect.app"
    private var loggers: [LogCategory: Logger] = [:]

    public static let shared = AppLogger()

    private init() {
        // Initialiser les loggers pour chaque catégorie
        for category in LogCategory.allCases {
            loggers[category] = Logger(subsystem: subsystem, category: category.rawValue)
        }
    }

    /// Log un message avec niveau et catégorie
    public func log(
        _ message: String,
        level: LogLevel = .info,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let filename = (file as NSString).lastPathComponent
        let context = "[\(filename):\(line)] \(function)"
        let fullMessage = "\(level.rawValue) \(context) - \(message)"

        guard let logger = loggers[category] else { return }

        switch level {
        case .debug:
            logger.debug("\(fullMessage)")
        case .info:
            logger.info("\(fullMessage)")
        case .warning:
            logger.warning("\(fullMessage)")
        case .error:
            logger.error("\(fullMessage)")
        case .critical:
            logger.critical("\(fullMessage)")
        }

        // En DEBUG, aussi afficher dans la console
        #if DEBUG
        print(fullMessage)
        #endif
    }

    /// Log une erreur avec détails
    public func logError(
        _ error: Error,
        message: String? = nil,
        category: LogCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let errorMessage = message ?? "Error occurred"
        let fullMessage = "\(errorMessage): \(error.localizedDescription)"

        log(
            fullMessage,
            level: .error,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }

    /// Log une requête API
    public func logAPIRequest(
        method: String,
        url: String,
        statusCode: Int? = nil,
        duration: TimeInterval? = nil
    ) {
        var message = "\(method) \(url)"

        if let statusCode = statusCode {
            message += " → \(statusCode)"
        }

        if let duration = duration {
            message += " (\(String(format: "%.2f", duration * 1000))ms)"
        }

        let level: LogLevel = {
            guard let code = statusCode else { return .info }
            if code >= 500 { return .error }
            if code >= 400 { return .warning }
            return .info
        }()

        log(message, level: level, category: .api)
    }

    /// Log une opération d'authentification
    public func logAuth(_ message: String, success: Bool = true) {
        log(
            message,
            level: success ? .info : .error,
            category: .auth
        )
    }

    /// Log une opération de données
    public func logData(_ message: String, level: LogLevel = .info) {
        log(message, level: level, category: .data)
    }

    /// Log une opération UI
    public func logUI(_ message: String, level: LogLevel = .debug) {
        log(message, level: level, category: .ui)
    }
}

// MARK: - Log Category Extension

extension LogCategory: CaseIterable {}

// MARK: - Convenience Functions

/// Log global pour accès rapide
public func appLog(
    _ message: String,
    level: LogLevel = .info,
    category: LogCategory = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Task {
        await AppLogger.shared.log(
            message,
            level: level,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }
}

/// Log d'erreur global
public func appLogError(
    _ error: Error,
    message: String? = nil,
    category: LogCategory = .general,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    Task {
        await AppLogger.shared.logError(
            error,
            message: message,
            category: category,
            file: file,
            function: function,
            line: line
        )
    }
}
