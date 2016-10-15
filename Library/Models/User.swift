import Foundation

struct User {
    static func light() -> [[String : Any]] {
        var users = [[String : Any]]()
        for _ in 0..<500 {
            users.append(self.generate())
        }

        return users
    }

    static func generate() -> [String : Any] {
        let id = UUID().uuidString
        let title = UUID().uuidString

        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let createdDate = dateFormatter.string(from: Date())

        return [
            "id" : id,
            "title": title,
            "createdDate": createdDate
        ]
    }
}
