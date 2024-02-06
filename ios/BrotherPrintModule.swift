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


    AsyncFunction("startSearchBluetoothPrinter2") { (promise: Promise) in
      #if targetEnvironment(simulator)
        promise.resolve("Cannot find printers via bluetooth when using a simulator.");    
      #else
       let foundPrinters: NSMutableArray = []
       let option = BRLMBLESearchOption()
            option.searchDuration = 15
            let result = BRLMPrinterSearcher.startBLESearch(option) { channel in
                let modelName = channel.extraInfo?.value(forKey: BRLMChannelExtraInfoKeyModelName) as? String ?? ""
                let serialNumber = channel.extraInfo?.value(forKey: BRLMChannelExtraInfoKeySerialNumber) as? String ?? ""
                let advertiseLocalName = channel.channelInfo
                let printerObject: NSMutableDictionary = [:]
                printerObject["modelName"] = modelName
                printerObject["printerName"] = advertiseLocalName
                printerObject["serialNumber"] = serialNumber
                foundPrinters.add(printerObject)
                print("Model : \(modelName), AdvertiseLocalName: \(advertiseLocalName)")
                
            }
            promise.resolve(foundPrinters);
      #endif 
    }

    

    AsyncFunction("printSamplePDF") { (strModelName: String, strSerialNumber: String,  strPrinterName: String, promise: Promise) in
        #if targetEnvironment(simulator)
          promise.resolve("Cannot print PDF when using a simulator.");    
        #else
          let channel = BRLMChannel(bluetoothSerialNumber: strSerialNumber)

          let generateResult = BRLMPrinterDriverGenerator.open(channel)
          guard generateResult.error.code == BRLMOpenChannelErrorCode.noError,
              let printerDriver = generateResult.driver else {
                 promise.resolve("Error - Open Channel: \(generateResult.error.code)")
                return
              }
          defer {
              printerDriver.closeChannel()
          }

          // Set your paper information
          let margins = BRLMCustomPaperSizeMargins(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
          let customPaperSize = BRLMCustomPaperSize(
            dieCutWithTapeWidth: CGFloat(4),
                                  tapeLength: CGFloat(6),
                                  margins: BRLMCustomPaperSizeMargins(top: 0.12, left: 0.06, bottom: 0.12, right: 0.06),
                                  gapLength: CGFloat(0.125),
                                  unitOfLength:  BRLMCustomPaperSizeLengthUnit.inch
                              )

          let myUrl = Bundle.main.url(forResource: "samplepdf2", withExtension: "pdf")

          //we have to prep the BRLMPrinterModel and base that on the strModelName passed
          //brute force, but with the guard the printSettings weren't in scope, so I put it in both the if and else
          if (strModelName == "RJ-4230B") { //belt printer model that DDL uses
              guard
                let printSettings = BRLMRJPrintSettings(defaultPrintSettingsWith: BRLMPrinterModel.RJ_4230B)
              else {
                 promise.resolve("Error - PDF file is not found.")
                return
              }
              printSettings.customPaperSize = customPaperSize
              let printError = printerDriver.printPDF(with: myUrl!, settings: printSettings)
              
              if printError.code != .noError {
                  promise.resolve("Error - Print PDF: \(printError.code)")
              }
              else {
                   promise.resolve("Success - Print PDF")
              }
          }
          else { //default to desktop printer
              //this one uses BRLMTDPrintSettings instead of BRLMRJPrintSettings
              guard
                let printSettings = BRLMTDPrintSettings(defaultPrintSettingsWith: BRLMPrinterModel.TD_4550DNWB)
              else {
                 promise.resolve("Error - PDF file is not found.")
                return
              }
              printSettings.customPaperSize = customPaperSize
              let printError = printerDriver.printPDF(with: myUrl!, settings: printSettings)
              
              if printError.code != .noError {
                   promise.resolve("Error - Print PDF: \(printError.code)")
              }
              else {
                  promise.resolve("Success - Print PDF")
              }
          }
        #endif 
      }
    }
}
