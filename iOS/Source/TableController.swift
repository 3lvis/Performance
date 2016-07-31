import UIKit
import DATASource
import JSON
import Sync
import DATAStack

class TableController: UITableViewController {
    unowned var dataStack: DATAStack

    init(dataStack: DATAStack) {
        self.dataStack = dataStack

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var dataSource: DATASource = {
        let request = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        request.fetchBatchSize = 100

        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack.mainContext) { cell, item, indexPath in
            cell.textLabel?.text = "\(indexPath.row): \(item.valueForKey("title") as? String ?? ""))"
        }
        
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.startAction))
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.startAction {}
    }

    var backgroundContext: NSManagedObjectContext {
        let context = self.dataStack.newNonMergingBackgroundContext()

        return context
    }

    func startAction(completion: (Void -> Void)) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        self.activityIndicator.startAnimating()

        self.backgroundContext.performBlock {
            let users = User.light()
            Sync.changes(users, inEntityNamed: "User", predicate: nil, parent: nil, inContext: self.backgroundContext, dataStack: self.dataStack, operations: [.Insert]) { error in
                self.activityIndicator.stopAnimating()
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.startAction))
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.startAction {}
                }
            }
        }
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
