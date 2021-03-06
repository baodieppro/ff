//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Shared

extension BrowserViewController: InterceptorUI {
    func showAntiPhishingAlert(tab: Tab, url: URL, policy: InterceptorPolicy) {
        let domainName = url.normalizedHost ?? ""

        let alert = UIAlertController(
            title: Strings.InterceptorUIAntiPhishingTitle,
            message: String(format: Strings.InterceptorUIAntiPhishingMessage, domainName),
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: Strings.InterceptorUIAntiPhishingBack, style: .default, handler: { (action) in
            if tab.url == url {
                tab.goBack()
            }
        }))

        alert.addAction(UIAlertAction(title: Strings.InterceptorUIAntiPhishingContinue, style: .destructive, handler: { (action) in
            policy.whitelistUrl(url)
            // TO DO : reload works only after second try. Same bug we have in old Cliqz. We need to investigate.
            tab.loadRequest(PrivilegedRequest(url: url) as URLRequest)
        }))

        self.present(alert, animated: true, completion: nil)
    }
}
