import UIKit
import DATAStack

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?

    lazy var dataStack: DATAStack = {
        let dataStack = DATAStack(modelName: "DataModel")

        return dataStack
    }()
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = self.window else { fatalError("Window not found") }

        let rootController = TableController(dataStack: self.dataStack)
        let navigationController = UINavigationController(rootViewController: rootController)
        window.rootViewController = navigationController        
        window.makeKeyAndVisible()

        return true
    }
}
