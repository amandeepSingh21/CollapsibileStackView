## 1. Collapsibile StackView Consumer App


## 2. Requirements
- iOS 11.0+
- [Xcode 11.3.1+]
- [SPM]


## 3. How To Use
Basic:
```
import CollapsibileStackView

let collapsibleStackView = CollapsibleStackView()

self.view.addSubview(collapsibleStackView)
collapsibleStackView.delegate = self
collapsibleStackView.datasource = self
```

To show the next card call:
```
self.collapsibleStackView.showNextCard()
```

To reload the header or body:
```
collapsibleStackView.reloadBody(at: index)
collapsibleStackView.reloadHeader(at: index)
```
Note: Caller can provide a header view and a body view in the data source. Similarly touch events can be handeled via the delegate.


## 4. Architecture
- This project is heavily inspired from UICollectionView/UITableView APIs.
- Delegates and Datasource pattern is used to provide a customization point for the caller.
- StackView is encapsulated inside a SPM package.
- Four states: Expanded, Collapsed, PartiallyCollapsed and PartiallyExpanded are used to meet the requirements.

