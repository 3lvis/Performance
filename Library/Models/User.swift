import Foundation

struct User {
    static func light() -> [[String : AnyObject]] {
        var users = [[String : AnyObject]]()
        for _ in 0..<2000 {
            users.append(self.generate())
        }

        return users
    }

    static func generate() -> [String : AnyObject] {
        let id = NSUUID().UUIDString
        let firstName = NSUUID().UUIDString
        let lastName = NSUUID().UUIDString

        return [
            "id" : id,
            "first_name": firstName,
            "last_name": lastName
        ]
    }
}