//
//  SearchResultsViewController.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 27.08.19.
//  Copyright © 2019 Mozilla. All rights reserved.
//

import Foundation
import React

/// Displays Cliqz Search Results
///
/// - Warning: This view controller will *not* layout its subviews. So in order to use this,
///     - add an instance of SearchResultsViewController as a child view controller
///     - add `.view` as a subview to your view
///     - add constraints for `.view`
///     - ALSO add constraints for `.searchView` (!!!)
class SearchResultsViewController: UIViewController, ReactViewTheme {
    public var isLastCharacterRemoved = false

    // MARK: Properties
    public private(set) var lastQuery: String = ""

    public var searchQuery: String = "" {
        didSet {
            var keyCode = ""
            let lastStringLength = lastQuery.count

            if lastStringLength - searchQuery.count == 1 {
                keyCode = "Backspace"
                self.isLastCharacterRemoved = true
            } else if searchQuery.count > lastStringLength {
                keyCode = "Key" + String(searchQuery.last!).uppercased()
                self.isLastCharacterRemoved = false
            }

            lastQuery = searchQuery

            startSearch(keyCode)
        }
    }

    public let searchView: UIView = {
        RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: "SearchResults",
            initialProperties: ["theme": SearchResultsViewController.getTheme()]
        )
    }()

    private let profile: Profile

    // MARK: - Initialization
    init(profile: Profile, isPrivate: Bool) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView.backgroundColor = .clear
        view.addSubview(searchView)
        applyTheme()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSearch()
    }

    // MARK: - Public API
    func handleKeyCommands(sender: UIKeyCommand) {

    }
}

// MARK: - Themeable
extension SearchResultsViewController: Themeable {
    func applyTheme() {
        view.backgroundColor = UIColor.clear
        updateTheme()
    }
}

// MARK: - Private API
extension SearchResultsViewController: BrowserCoreClient {
    private func startSearch(_ keyCode: String) {
        browserCore.callAction(module: "search", action: "startSearch", args: [
            searchQuery,
            ["keyCode": keyCode],
            ["contextId": "mobile-cards"],
        ])
    }

    private func stopSearch() {
        browserCore.callAction(module: "search", action: "stopSearch", args: [
            ["entryPoint": ""],
            ["contextId": "mobile-cards"],
        ])
    }

    private func updateTheme() {
         browserCore.callAction(
           module: "BrowserCore",
           action: "changeTheme",
           args: [Self.getTheme()]
         )
    }
}
