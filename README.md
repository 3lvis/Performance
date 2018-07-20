# Sync Performance

Shows Sync's performance of loading tens of thousands objects without blocking the main thread.

The core idea is to use DATAStack's nonMergingContext. Since it doesn't merge things back to the main thread, you need to call NSFetchedResultsController's fetch method and reload your tableView or collectionView. 

## Running the project

- Clone the project 

```
git@github.com:3lvis/Performance.git
```

- Open `Project.xcworkspace`
