![](docs/stackview.gif)

## 1. Collapsibile StackView Consumer App

Assignment by [Amandeep](mailto:amandeep.saluja21@gmail.com).

![](docs/Screenshot.png)

## 2. Requirements
- iOS 11.0+
- [Xcode 11.3.1+]
- [SPM]


## 3. Getting Started
- Open `CollapsibleStackViewConsumer.xcodeproj` in Xcode 11.3.1+
- Wait for SPM to fetch the dependecy and build the project

## 4. Problem Statements
[Problem Statements](docs/problem_statement.pdf)

## 5. Swift
This project is build using Swift 5.

## 6. Architecture
- This project is heavily inspired from UICollectionView/UITableView APIs.
- Delegates and Datasource pattern is used to provide a customization point for the caller.
- StackView is encapsulated inside a SPM package.
- Four states: Expanded, Collapsed, PartiallyCollapsed and PartiallyExpanded are used to meet the requirements.
