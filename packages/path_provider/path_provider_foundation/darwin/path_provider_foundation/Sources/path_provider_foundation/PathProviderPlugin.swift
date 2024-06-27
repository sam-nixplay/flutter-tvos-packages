import Foundation
#if canImport(Flutter)
  import Flutter
#elseif canImport(FlutterMacOS)
  import FlutterMacOS
#endif

public class PathProviderPlugin: NSObject, FlutterPlugin, PathProviderApi {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let messenger = registrar.messenger()
    let instance = PathProviderPlugin()
    PathProviderApiSetup.setUp(binaryMessenger: messenger, api: instance)
  }

  func getDirectoryPath(type: DirectoryType) throws -> String? {
    print("getDirectoryPath called for type: \(type)")
    let isTvOS = ProcessInfo.processInfo.environment["TV_MODE"] == "ON"
    print("Is tvOS: \(isTvOS)")
    
    var searchPathDirectory: FileManager.SearchPathDirectory
    switch type {
    case .applicationSupport:
      searchPathDirectory = .applicationSupportDirectory
    case .applicationCache:
      searchPathDirectory = .cachesDirectory
    case .applicationDocuments:
      searchPathDirectory = isTvOS ? .cachesDirectory : .documentDirectory
    case .downloads:
      if isTvOS {
        print("Downloads directory not available on tvOS")
        return nil
      }
      searchPathDirectory = .downloadsDirectory
    case .library:
      searchPathDirectory = .libraryDirectory
    case .temp:
      return NSTemporaryDirectory()
    }
    
    let paths = NSSearchPathForDirectoriesInDomains(
      searchPathDirectory,
      .userDomainMask,
      true
    )
    return paths.first
  }

  func getContainerPath(appGroupIdentifier: String) throws -> String? {
    return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?.path
  }
}