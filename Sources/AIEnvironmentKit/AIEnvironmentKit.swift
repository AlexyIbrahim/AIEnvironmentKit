import Foundation
import UIKit
import SystemConfiguration
import QuartzCore
//import SwiftOverlayShims

public enum AIEnvironment {
    case simulator
    case debug
    case adhoc
    case testfligt
    case appStore
    case other
}

public class AIEnvironmentKit {
    // MARK: - environment
    public static var environment: AIEnvironment = {
        if AIEnvironmentKit.isSimulator {
            return .simulator
        }
        
        if AIEnvironmentKit.isDebug {
            return .debug
        }
        
        if AIEnvironmentKit.isAdHoc {
            return .adhoc
        }
        
        if AIEnvironmentKit.isTestflight {
            return .testfligt
        }
        
        if AIEnvironmentKit.isAppStore {
            return .appStore
        }
        
        return .other
    }()
    
    @objc public static var environmentName: String {
        switch AIEnvironmentKit.environment {
        case .simulator:
            return "simulator"
        case .debug:
            return "debug"
        case .adhoc:
            return "adhoc"
        case .testfligt:
            return "testflight"
        case .appStore:
            return "appStore"
        case .other:
            return "other"
        }
    }
    
    @objc public static var isSimulator: Bool = {
        #if targetEnvironment(simulator) // #if TARGET_OS_SIMULATOR
        return true
        #else
        return false
        #endif
    }()
    
    @objc public static var isDebug: Bool = {
        if AIEnvironmentKit.isSimulator {
            return true
        } else {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }()
    
    @objc public static var isAdHoc: Bool = {
        if AIEnvironmentKit.isSimulator {
            return false
        } else {
            if AIEnvironmentKit.hasEmbeddedMobileProvision {
                return true
            }
            return false
        }
    }()
    
    @objc public static var isTestflight: Bool = {
        if AIEnvironmentKit.isSimulator {
            return false
        } else {
            if AIEnvironmentKit.isAppStoreReceiptSandbox && !AIEnvironmentKit.hasEmbeddedMobileProvision {
                return true
            } else {
                return false
            }
        }
    }()
    
    @objc public static var isAppStore: Bool = {
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
    
    @objc public static var isRelease: Bool = {
        if AIEnvironmentKit.isSimulator {
            return false
        } else {
            #if !DEBUG
            return true
            #else
            return false
            #endif
        }
    }()
    
    // MARK: - miscellaneous
    @objc public static let isRunningInAppExtension: Bool = {
        var isRunningInAppExtension = (Bundle.main.executablePath as NSString?)?.range(of: ".appex/").location != NSNotFound
        return isRunningInAppExtension
    }()
    
    @objc public static let isDebuggerAttached: Bool = {
        var debuggerIsAttached = false
        
        var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var info: kinfo_proc = kinfo_proc()
        var info_size = MemoryLayout<kinfo_proc>.size
        
        let success = name.withUnsafeMutableBytes { (nameBytePtr: UnsafeMutableRawBufferPointer) -> Bool in
            guard let nameBytesBlindMemory = nameBytePtr.bindMemory(to: Int32.self).baseAddress else { return false }
            return -1 != sysctl(nameBytesBlindMemory, 4, &info, &info_size, nil, 0)
        }
        
        if !success {
            debuggerIsAttached = false
        }
        
        if !debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0 {
            debuggerIsAttached = true
        }
        
        return debuggerIsAttached
        
        //        var info = kinfo_proc()
        //        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        //        var size = MemoryLayout<kinfo_proc>.stride
        //        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        //        assert(junk == 0, "sysctl failed")
        //        return (info.kp_proc.p_flag & P_TRACED) != 0
    }()
    
    @objc public static let isCableConnected: Bool = {
        let currentState = UIDevice.current.batteryState
        if currentState == .charging || currentState == .full {
            return true
        }
        return false
    }()
    
    
    // MARK: - other / private
    // 🌿 MobilePovision profiles are a clear indicator for Ad-Hoc distribution
    @objc private static var hasEmbeddedMobileProvision: Bool = {
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
    
    @objc private static var isAppStoreReceiptSandbox: Bool = {
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
    
    
}

// MARK: - public methods
extension AIEnvironmentKit {
    /**
     Execute if Xcode debugger is attached
     
     - Author:
     Alexy
    */
    @objc public final class func executeIfDebuggerAttached(code: () -> ()) {
        if AIEnvironmentKit.isDebuggerAttached {
            code()
        }
    }
    
    /**
     Execute if built with development certificate
     
     - Author:
     Alexy
    */
    @objc public final class func executeIfDebug(code: () -> ()) {
        if AIEnvironmentKit.isDebug {
            code()
        }
    }
    
    /**
     Execute if on 3rd paty distribution, i.e: Firebase, Diawi, etc
     
     - Author:
     Alexy
    */
    @objc public final class func executeIfAdhoc(code: () -> ()) {
        if AIEnvironmentKit.isAdHoc {
            code()
        }
    }
    
    /**
     Execute if not on the App Store
     
     - Author:
     Alexy
    */
    @objc public final class func executeIfNotAppStore(code: () -> ()) {
        if !AIEnvironmentKit.isAppStore {
            code()
        }
    }
    
    /**
     Execute if on the App Store
     
     - Author:
     Alexy
    */
    @objc public final class func executeAppStore(code: () -> ()) {
        if AIEnvironmentKit.isAppStore {
            code()
        }
    }
    
    /**
     Provide 2 execution scenarios, if on the App Store and not on the App Store
     
     - Author:
     Alexy
    */
    @objc public final class func execute(notAppStore: () -> (), appStore: () -> ()) {
        if !AIEnvironmentKit.isAppStore {
            notAppStore()
        } else {
            appStore()
        }
    }
}
