import Foundation

struct User {
    static func light() -> [[String : AnyObject]] {
        var users = [[String : AnyObject]]()
        for _ in 0..<100 {
            users.append(self.generate())
        }

        return users
    }

    static func generate() -> [String : AnyObject] {
        let id = NSUUID().UUIDString
        let firstName = NSUUID().UUIDString
        let lastName = NSUUID().UUIDString

        let dateFormatter = NSDateFormatter()
        let enUSPosixLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let createdDate = dateFormatter.stringFromDate(NSDate())

        return [
            "id" : id,
            "first_name": firstName,
            "last_name": lastName,
            "createdDate": createdDate
        ]
    }
}