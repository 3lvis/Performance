import UIKit
import DATASource
import JSON
import Sync
import DATAStack

class RootController: BaseTableViewController {
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

    var backgroundContext: NSManagedObjectContext {
        let context = self.dataStack.newBackgroundContext()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RootController.backgroundContextDidSave(_:)), name: NSManagedObjectContextDidSaveNotification, object: context)
        return context
    }

    func backgroundContextDidSave(notification: NSNotification) throws {
        self.dataStack.writerContext.mergeChangesFromContextDidSaveNotification(notification)
    }

    func startAction() {
        self.activityIndicator.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(self.cancelAction))

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let users = User.light()
            self.backgroundContext.performBlock {
                Sync.changes(users, inEntityNamed: "User", predicate: nil, parent: nil, inContext: self.backgroundContext, dataStack: self.dataStack) { error in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dataSource.fetch()
                        //self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.navigationItem.rightBarButtonItem = nil
                    }
                }
            }
        }
    }

    func cancelAction() {
        self.activityIndicator.stopAnimating()
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        self.performSelector(#selector(scrollViewDidEndScrollingAnimation), withObject: nil, afterDelay: 0.3)
    }

    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        self.dataSource.fetch()
        self.tableView.reloadData()
    }
}
