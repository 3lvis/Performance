# Sync Performance

Shows Sync's performance of loading tens of thousands objects without blocking the main thread.

The core idea is to use DATAStack's nonMergingContext. Since it doesn't merge things back to the main thread, you need to call NSFetchedResultsController's fetch method and reload your tableView or collectionView. 

## Running the project

- Install the [cocoapods](https://cocoapods.org) gem

```
sudo gem install cocoapods
```

- Run the following command in Terminal.app

```
pod install
```

- Open `Project.xcworkspace`
