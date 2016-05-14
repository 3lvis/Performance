import Foundation
import DATAStack
import Networking
import Sync
import DATASource
import CoreData

public class Fetcher {
    var dataStack: DATAStack
    var networking: Networking

    init(baseURL: String, modelName: String) {
        self.dataStack = DATAStack(modelName: modelName)
        self.networking = Networking(baseURL: baseURL)
        self.networking.fakeGET("/initialImport", fileName: "initial-import.json")
        self.networking.fakeGET("/hugeImport", fileName: "huge-import.json")
    }

    public func initialImport(completion: (error: NSError?) -> ()) {
        self.networking.GET("/initialImport") { JSON, error in
            if let JSON = JSON as? [[String : AnyObject]] {
                Sync.changes(JSON, inEntityNamed: "User", dataStack: self.dataStack, completion: { error in
                    completion(error: error)
                })
            } else {
                completion(error: error)
            }
        }
    }

    public func bigImport(completion: (error: NSError?) -> ()) {
        self.networking.GET("/hugeImport") { JSON, error in
            if let JSON = JSON as? [[String : AnyObject]] {
                Sync.changes(JSON, inEntityNamed: "User", dataStack: self.dataStack, completion: { error in
                    completion(error: error)
                })
            } else {
                completion(error: error)
            }
        }
    }
}

extension Fetcher {
    public func dataSource(tableView: UITableView, cellIdentifier: String, fetchRequest: NSFetchRequest, sectionName: String? = nil, configuration: (cell: UITableViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ()) -> DATASource {
        return DATASource(tableView: tableView, cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, mainContext: self.dataStack.mainContext, sectionName: sectionName, configuration: configuration)
    }

    public func dataSource(collectionView: UICollectionView, cellIdentifier: String, fetchRequest: NSFetchRequest, mainContext: NSManagedObjectContext, sectionName: String? = nil, configuration: (cell: UICollectionViewCell, item: NSManagedObject, indexPath: NSIndexPath) -> ()) -> DATASource {
        return DATASource(collectionView: collectionView, cellIdentifier: cellIdentifier, fetchRequest: fetchRequest, mainContext: self.dataStack.mainContext, sectionName: sectionName, configuration: configuration)
    }
}
