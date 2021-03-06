/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit
import Shared
/**
 Firefox-specific implementation of tab content blocking.
 */
class FirefoxTabContentBlocker: TabContentBlocker, TabContentScript {
    let userPrefs: Prefs

    class func name() -> String {
        return "TrackingProtectionStats"
    }

    override var isEnabledTrackingProtection: Bool {
        return self.userPrefs.boolForKey(PrefsKeys.TrackingProtectionEnabledKey) ?? true
    }

    override var isEnabledAdBlocking: Bool {
        return self.userPrefs.boolForKey(PrefsKeys.AdBlockingEnabledKey) ?? true
    }

    init(tab: ContentBlockerTab, prefs: Prefs) {
        userPrefs = prefs
        super.init(tab: tab)
        setupForTab()
    }

    func setupForTab() {
        guard let tab = tab else { return }
        let adsRules = BlocklistName.ads
        ContentBlocker.shared.setupTrackingProtection(forTab: tab, isEnabled: self.isEnabledAdBlocking, rules: adsRules)
        let trackingRules = BlocklistName.tracking
        ContentBlocker.shared.setupTrackingProtection(forTab: tab, isEnabled: self.isEnabledTrackingProtection, rules: trackingRules)
    }

    @objc override func notifiedTabSetupRequired() {
        setupForTab()
    }

    override func currentlyEnabledLists() -> [BlocklistName] {
        var list = [BlocklistName]()
        if self.isEnabledAdBlocking {
            list.append(contentsOf: BlocklistName.ads)
        }
        if self.isEnabledTrackingProtection {
            list.append(contentsOf: BlocklistName.tracking)
        }
        return list
    }

    override func notifyContentBlockingChanged() {
        guard let tab = tab as? Tab else { return }
        TabEvent.post(.didChangeContentBlocking, for: tab)
    }
}

// Static methods to access user prefs for tracking protection
extension FirefoxTabContentBlocker {

    static func setTrackingProtection(enabled: Bool, prefs: Prefs, tabManager: TabManager) {
        prefs.setBool(enabled, forKey: PrefsKeys.TrackingProtectionEnabledKey)
        ContentBlocker.shared.prefsChanged()
    }

    static func setAdBlocking(enabled: Bool, prefs: Prefs, tabManager: TabManager) {
        prefs.setBool(enabled, forKey: PrefsKeys.AdBlockingEnabledKey)
        ContentBlocker.shared.prefsChanged()
    }

    static func isTrackingProtectionEnabled(tabManager: TabManager) -> Bool {
        guard let blocker = tabManager.selectedTab?.contentBlocker else { return false }
        return blocker.isEnabledTrackingProtection
    }

    static func isAdBlockingEnabled(tabManager: TabManager) -> Bool {
        guard let blocker = tabManager.selectedTab?.contentBlocker else { return false }
        return blocker.isEnabledAdBlocking
    }

    static func toggleTrackingProtectionEnabled(prefs: Prefs, tabManager: TabManager) {
        let isEnabled = FirefoxTabContentBlocker.isTrackingProtectionEnabled(tabManager: tabManager)
        self.setTrackingProtection(enabled: !isEnabled, prefs: prefs, tabManager: tabManager)
    }

    static func toggleAdBlockingEnabled(prefs: Prefs, tabManager: TabManager) {
        let isEnabled = FirefoxTabContentBlocker.isAdBlockingEnabled(tabManager: tabManager)
        self.setAdBlocking(enabled: !isEnabled, prefs: prefs, tabManager: tabManager)
    }

}
