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
        promise.resolve("Cannot find printers via wifi when using a simulator.");    
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

    AsyncFunction("startSearchBluetoothPrinter") { (promise: Promise) in
      #if targetEnvironment(simulator)
        promise.resolve("Cannot find printers via bluetooth when using a simulator.");    
      #else
        let devices = BRPtouchBluetoothManager.shared().pairedDevices()  as! [BRPtouchDeviceInfo]; //discover bluetooth printers

        let foundPrinters: NSMutableArray = []
        for deviceInfo in devices { //there should only be one
            if let deviceInfo = deviceInfo as? BRPtouchDeviceInfo {
              let printerObject: NSMutableDictionary = [:]
              printerObject["modelName"] = deviceInfo.strModelName
              printerObject["printerName"] = deviceInfo.strPrinterName
              printerObject["serialNumber"] = deviceInfo.strSerialNumber
              foundPrinters.add(printerObject)
            }
        }
        promise.resolve(foundPrinters);
      #endif 
    }
  }
}