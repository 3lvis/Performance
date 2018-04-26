import UIKit
import DATASource
import JSON
import Sync

class TableController: UITableViewController {
    unowned var dataStack: DataStack

    init(dataStack: DataStack) {
        self.dataStack = dataStack

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var dataSource: DATASource = {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        request.fetchBatchSize = 100
        
        let dataSource = DATASource(tableView: self.tableView, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack.mainContext, configuration: { cell, item, indexPath in
            let title = item.value(forKey: "title") as? String ?? ""
            cell.textLabel?.text = "\(indexPath.row): \(title)"
        })
        
        return dataSource
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .white)
        view.color = .black

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.dataSource = self.dataSource
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.startAction))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.startAction()
    }

    var backgroundContext: NSManagedObjectContext {
        let context = self.dataStack.newNonMergingBackgroundContext()

        return context
    }

    @objc func startAction() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        self.activityIndicator.startAnimating()

        self.backgroundContext.perform {
            let users = User.light()
            Sync.changes(users, inEntityNamed: "User", predicate: nil, parent: nil, parentRelationship: nil, inContext: self.backgroundContext, operations: .insert)
            { error in
                self.activityIndicator.stopAnimating()
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.startAction))
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.startAction()
                }
            }
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(scrollViewDidEndScrollingAnimation), with: nil, afterDelay: 0.3)
    }

    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.dataSource.fetch()
        self.tableView.reloadData()
    }
}
