import UIKit
import DATASource
import JSON
import Sync

class RootController: BaseTableViewController {
    var operation: Sync?

    lazy var dataSource: DATASource = {
        let request = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.fetchBatchSize = 100

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack.mainContext, configuration: { cell, item, indexPath in
            cell.textLabel?.text = "\(item.valueForKey("firstName") as? String ?? "") \(item.valueForKey("lastName") as? String ?? "")"
        })
        
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.dataSource = self.dataSource
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: #selector(cancelAction))

        let users = try! JSON.from("huge-import.json") as! [[String : AnyObject]]
        // let users = try! JSON.from("initial-import.json") as! [[String : AnyObject]]
        self.operation = Sync(changes: users, inEntityNamed: "User", predicate: nil, dataStack: self.dataStack)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.operation?.start()
    }

    func cancelAction() {
        self.operation?.cancel()
    }
}
