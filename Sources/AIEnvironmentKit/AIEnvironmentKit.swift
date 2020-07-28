import Foundation
import UIKit

enum AIEnvironment {
    case simulator
    case debug
    case adhoc
    case appStore
    case cableBuild
}

public class AIEnvironmentKit {
    @objc static var isCableBuild: Bool = {
        let currentState = UIDevice.current.batteryState
        if currentState == .charging || currentState == .full {
            if AIEnvironmentKit.isDebug {
                return true
            }
        }
        return false
    }()
    
    @objc static var isDebug: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
//    @objc static var isRunningInTestFlightEnvironment: Bool = {
//        if isSimulator() {
//            return false
//        } else {
//            if isAppStoreReceiptSandbox() && !hasEmbeddedMobileProvision() {
//                return true
//            } else {
//                return false
//            }
//        }
//    }()
    
    @objc static var isAdHoc: Bool = {
        if !AIEnvironmentKit.isDebug && AIEnvironmentKit.isDebugOrAdhoc {
            return true
        }
        return false
    }()
    
    @objc static var isRelease: Bool = {
        #if !DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    @objc static var isDebugOrAdhoc: Bool = {
        if AIEnvironmentKit.isSimulator {
            return true
        } else {
            if AIEnvironmentKit.hasEmbeddedMobileProvision {
                return true
            }
            return false
        }
    }()
    
    
    
    @objc static var environmentName: String {
        if AIEnvironmentKit.isDebug {
            return "debug"
        } else if AIEnvironmentKit.isAdHoc {
            return "adhoc"
        } else {
            return "release"
        }
    }
    
    @objc static var isSimulator: Bool = {
        #if targetEnvironment(simulator) // #if TARGET_OS_SIMULATOR
        return true
        #else
        return false
        #endif
    }()
    
    func bit_currentAppEnvironment() -> BITEnvironment {
        if AIEnvironmentKit.isSimulator {
            return BITEnvironmentOther
        } else {
            
            // MobilePovision profiles are a clear indicator for Ad-Hoc distribution
            if bit_hasEmbeddedMobileProvision() {
                return BITEnvironmentOther
            }
            
            if bit_isAppStoreReceiptSandbox() {
                return BITEnvironmentTestFlight
            }
            
            return BITEnvironmentAppStore
        }
    }
    
    @objc static var isAppStore: Bool = {
        if AIEnvironmentKit.isSimulator {
            return false
        } else {
            if AIEnvironmentKit.isAppStoreReceiptSandbox || AIEnvironmentKit.hasEmbeddedMobileProvision {
                return false
            } else {
                return true
            }
        }
    }()
    
    @objc static var isAppStoreReceiptSandbox: Bool = {
        if AIEnvironmentKit.isSimulator {
            return false
        } else {
            if !Bundle.main.responds(to: #selector(getter: Bundle.appStoreReceiptURL)) {
                return false
            }
            let appStoreReceiptURL = Bundle.main.appStoreReceiptURL
            let appStoreReceiptLastComponent = appStoreReceiptURL?.lastPathComponent
            
            let isSandboxReceipt = appStoreReceiptLastComponent == "sandboxReceipt"
            return isSandboxReceipt
        }
    }()
    
    @objc static var hasEmbeddedMobileProvision: Bool = {
        //        if let _ = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") {
        //            return true
        //        }
        //        return false
        
        let data = NSData(contentsOfFile: Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") ?? "") as Data?
        guard data != nil else {
            return false
        }
        return true
    }()
}

// 🌿 methods
extension AIEnvironmentKit {
    @objc final class func executeIfCableBuild(callback: () -> ()) {
        if AIEnvironmentKit.isCableBuild {
            callback()
        }
    }
    
    @objc final class func executeIfDebug(callback: () -> ()) {
        if AIEnvironmentKit.isDebug {
            callback()
        }
    }
    
    @objc final class func executeIfDebugOrAdhoc(callback: () -> ()) {
        if AIEnvironmentKit.isDebug || AIEnvironmentKit.isAdHoc {
            callback()
        }
    }
    
    @objc final class func executeIfRelease(callback: () -> ()) {
        if AIEnvironmentKit.isRelease {
            callback()
        }
    }
    
    @objc final class func execute(debugAdhoc: () -> (), release: () -> ()) {
        if AIEnvironmentKit.isDebug || AIEnvironmentKit.isAdHoc {
            debugAdhoc()
        } else {
            release()
        }
    }
}
