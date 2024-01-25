import ExpoModulesCore
import BRLMPrinterKit

public class BrotherPrintModule: Module {
  public func definition() -> ModuleDefinition {
    Name("BrotherPrint")

    Function("startSearchWiFiPrinter") { () -> Void in
      let manager = BRPtouchNetworkManager();
      manager.startSearch(5);
      let devices = manager.getPrinterNetInfo()  as! [BRPtouchDeviceInfo];
      var printers = "";
      for deviceInfo in devices {
          if let deviceInfo = deviceInfo as? BRPtouchDeviceInfo {
              printers += deviceInfo.strModelName + " ";
          }
      }
      return devices as! [BRPtouchDeviceInfo];
    }
  }
}