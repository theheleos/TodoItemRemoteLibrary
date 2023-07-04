import Foundation

public struct TodoItem {
    public let id: String
    public let text: String
    public let importance: Importance
    public let dateDeadline: Date?
    public let isDone: Bool
    public let dateСreation: Date
    public let dateChanging: Date?

    public init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        dateDeadline: Date? = nil,
        isDone: Bool = false,
        dateСreation: Date = Date(),
        dateChanging: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.dateDeadline = dateDeadline
        self.isDone = isDone
        self.dateСreation = dateСreation
        self.dateChanging = dateChanging
    }
}

// MARK: - Extensions

extension TodoItem {
    public static func parse(JSON: Any) -> TodoItem? {
        guard let json = JSON as? [String: Any] else { return nil }

        let importance = (json[JSONKeys.importance.rawValue] as? String).flatMap(Importance.init(rawValue: )) ?? .normal
        let isDone = json[JSONKeys.isDone.rawValue] as? Bool ?? false
        let dateDeadline = (json[JSONKeys.dateDeadline.rawValue] as? Double).flatMap { Date(timeIntervalSince1970: $0) }
        let dateChanging = (json[JSONKeys.dateChanging.rawValue] as? Double).flatMap { Date(timeIntervalSince1970: $0) }

        guard let id = json[JSONKeys.id.rawValue] as? String,
              let text = json[JSONKeys.text.rawValue] as? String,
              let dateCreation = (json[JSONKeys.dateСreation.rawValue] as? Double).flatMap({
                  Date(timeIntervalSince1970: $0)
              })
        else {
            return nil
        }

        return TodoItem(id: id,
                        text: text,
                        importance: importance,
                        dateDeadline: dateDeadline,
                        isDone: isDone,
                        dateСreation: dateCreation,
                        dateChanging: dateChanging)
    }

    public var json: Any {
        var jsonDict: [String: Any] = [:]

        jsonDict[JSONKeys.id.rawValue] = self.id
        jsonDict[JSONKeys.text.rawValue] = self.text
        if self.importance != .normal {
            jsonDict[JSONKeys.importance.rawValue] = self.importance.rawValue
        }
        if let dateDeadline = self.dateDeadline {
            jsonDict[JSONKeys.dateDeadline.rawValue] = dateDeadline.timeIntervalSince1970
        }
        jsonDict[JSONKeys.isDone.rawValue] = self.isDone
        jsonDict[JSONKeys.dateСreation.rawValue] = self.dateСreation.timeIntervalSince1970
        if let dateChanging = self.dateChanging {
            jsonDict[JSONKeys.dateChanging.rawValue] = dateChanging.timeIntervalSince1970
        }

        return jsonDict
    }
}

extension TodoItem {
    public static func parse(csv: String) -> TodoItem? {
        let columns = csv.components(separatedBy: CSVSeparator.semicolon.rawValue)

        let id = String(columns[0])
        let text = String(columns[1])
        let importance = Importance(rawValue: columns[2]) ?? .normal
        let isDone = Bool(columns[4]) ?? false
        let dateDeadline = Double(columns[3]).flatMap { Date(timeIntervalSince1970: $0) }
        let dateChanging = Double(columns[6]).flatMap { Date(timeIntervalSince1970: $0) }

        guard !id.isEmpty, !text.isEmpty, let dateCreation = Double(columns[5]).flatMap({
            Date(timeIntervalSince1970: $0)
        }) else {
            return nil
        }

        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            dateDeadline: dateDeadline,
            isDone: isDone,
            dateСreation: dateCreation,
            dateChanging: dateChanging
        )
    }

    public var csv: String {
        var csvDataArray: [String] = []

        csvDataArray.append(self.id)
        csvDataArray.append(self.text)
        if self.importance != .normal {
            csvDataArray.append(self.importance.rawValue)
        } else {
            csvDataArray.append("")
        }
        if let dateDeadline = self.dateDeadline {
            csvDataArray.append(String(dateDeadline.timeIntervalSince1970))
        } else {
            csvDataArray.append("")
        }
        csvDataArray.append(String(self.isDone))

        csvDataArray.append(String(self.dateСreation.timeIntervalSince1970))
        if let dateChanging = self.dateChanging {
            csvDataArray.append(String(dateChanging.timeIntervalSince1970))
        } else {
            csvDataArray.append("")
        }

        return csvDataArray.lazy.joined(separator: CSVSeparator.semicolon.rawValue)
    }
}

// MARK: - Enum

public enum Importance: String {
    case unimportant
    case normal
    case important

    public init?(rawValue: Int) {
        switch rawValue {
        case 0:
            self = .unimportant
        case 1:
            self = .normal
        case 2:
            self = .important
        default:
            return nil
        }
    }

    public var value: Int {
        switch self {
        case .unimportant:
            return 0
        case .normal:
            return 1
        case .important:
            return 2
        }
    }
}

public enum JSONKeys: String {
    case id
    case text
    case importance
    case dateDeadline = "date_deadline"
    case isDone = "is_done"
    case dateСreation = "date_creation"
    case dateChanging = "date_changing"
}

public enum CSVSeparator: String {
    case comma = ","
    case semicolon = ";"
}
