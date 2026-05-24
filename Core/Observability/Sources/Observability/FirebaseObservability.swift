#if canImport(FirebaseCore)
import Foundation
import FirebaseCore
#endif

public enum FirebaseObservability {
    public static func configureIfAvailable() {
        #if canImport(FirebaseCore)
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            print("[ModularShopLab][WARNING] firebase_configuration_missing - GoogleService-Info.plist not found.")
            return
        }

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        #endif
    }
}
