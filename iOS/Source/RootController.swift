import UIKit
import DATASource

class RootController: BaseTableViewController {
    lazy var dataSource: DATASource = {
        let request = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.fetchBatchSize = 100

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.fetcher.dataStack.mainContext, configuration: { cell, item, indexPath in
            cell.textLabel?.text = "\(item.valueForKey("firstName") as? String ?? "") \(item.valueForKey("lastName") as? String ?? "")"
        })
        
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.dataSource = self.dataSource
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        print("appeared")
//        self.fetcher.initialImport { error in
//            print("first batch")
//            self.fetcher.bigImport { error in
//                print("second batch")
//            }
//        }
    }
}
