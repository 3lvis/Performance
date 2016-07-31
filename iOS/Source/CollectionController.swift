import UIKit
import DATASource
import JSON
import Sync
import DATAStack

class CollectionController: UICollectionViewController {
    unowned var dataStack: DATAStack

    init(dataStack: DATAStack) {
        self.dataStack = dataStack

        let layout = UICollectionViewFlowLayout()
        let bounds = UIScreen.mainScreen().bounds
        let numberOfColumns = CGFloat(3)
        let size = (bounds.width - (numberOfColumns - 1)) / numberOfColumns
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var dataSource: DATASource = {
        let request = NSFetchRequest(entityName: "User")
        request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        request.fetchBatchSize = 100

        let dataSource = DATASource(collectionView: self.collectionView!, cellIdentifier: "Cell", fetchRequest: request, mainContext: self.dataStack.mainContext, configuration: { cell, item, indexPath in
            let cell = cell as! CollectionCell
            cell.textLabel.text = "\(indexPath.row): \(item.valueForKey("title") as? String ?? "")"
            print(cell.textLabel.text)
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

        self.collectionView?.registerClass(CollectionCell.self, forCellWithReuseIdentifier: "Cell")
        self.collectionView?.dataSource = self.dataSource
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

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.backgroundContext.performBlock {
                let users = User.light()
                Sync.changes(users, inEntityNamed: "User", predicate: nil, parent: nil, inContext: self.backgroundContext, dataStack: self.dataStack, operations: [.Insert]) { error in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.stopAnimating()
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.startAction))
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(4 * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            self.startAction {}
                        }
                    }
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
        self.collectionView?.reloadData()
    }
}
