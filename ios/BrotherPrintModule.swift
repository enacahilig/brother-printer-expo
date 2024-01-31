import ExpoModulesCore
#if targetEnvironment(simulator)
  //do nothing
#else
  import BRLMPrinterKit
#endif

public class BrotherPrintModule: Module {
  public func definition() -> ModuleDefinition {
    Name("BrotherPrint")

    AsyncFunction("startSearchWiFiPrinter") { (promise: Promise) in
        #if targetEnvironment(simulator)
          promise.resolve("Cannot find printers when using a simulator.");    
        #else
          let manager = BRPtouchNetworkManager();
            manager.startSearch(5);
            let devices = manager.getPrinterNetInfo()  as! [BRPtouchDeviceInfo];
            var printers = "";
            for deviceInfo in devices {
                if let deviceInfo = deviceInfo as? BRPtouchDeviceInfo {
                    printers += deviceInfo.strModelName + " ";
                }
            }
            promise.resolve( devices as! [BRPtouchDeviceInfo]);
        #endif 
      }
  }
}