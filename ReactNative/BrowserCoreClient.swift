//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

protocol BrowserCoreClient {
    var browserCore: JSBridge { get }
    static var browserCore: JSBridge { get }
}

extension BrowserCoreClient {
    var browserCore: JSBridge {
        return ReactNativeBridge.sharedInstance.browserCore
    }

    static var browserCore: JSBridge {
        return ReactNativeBridge.sharedInstance.browserCore
    }
}
