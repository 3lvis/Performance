import UIKit
import DATASource
import JSON
import Sync

class RootController: BaseTableViewController {
    static let OperationCountKeyPath = "operationCount"
    lazy var operationQueue: NSOperationQueue = {
        let object = NSOperationQueue()
        object.addObserver(self, forKeyPath: RootController.OperationCountKeyPath, options: .New, context: nil)

        return object
    }()

    lazy var dataSource: DATASource = {
        let request = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.fetchBatchSize = 100

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack.mainContext, configuration: { cell, item, indexPath in
            cell.textLabel?.text = "\(item.valueForKey("firstName") as? String ?? "") \(item.valueForKey("lastName") as? String ?? "")"
        })
        
        return dataSource
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .White)
        view.color = .blackColor()

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.dataSource = self.dataSource
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.startAction()
    }

    func startAction() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let users = try! JSON.from("huge-import.json") as! [[String : AnyObject]]
            let operation = Sync(changes: users, inEntityNamed: "User", predicate: nil, dataStack: self.dataStack)
            self.operationQueue.addOperation(operation)

            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicator.startAnimating()
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(self.cancelAction))
            }
        }
    }

    func cancelAction() {
        self.activityIndicator.stopAnimating()
        self.operationQueue.cancelAllOperations()
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let object = object else { return }
        if object.isEqual(self.operationQueue) && keyPath == RootController.OperationCountKeyPath {
            if self.operationQueue.operationCount == 0 {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(self.startAction))
                }
            }
        }
    }
}
