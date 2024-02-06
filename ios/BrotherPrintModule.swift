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
        /* Commenting prev code for now
        let manager = BRPtouchNetworkManager();
        manager.startSearch(5);
        let devices = manager.getPrinterNetInfo()  as! [BRPtouchDeviceInfo];
        var printers = "";
        for deviceInfo in devices {
            if let deviceInfo = deviceInfo as? BRPtouchDeviceInfo {
                printers += deviceInfo.strModelName + " ";
            }
        }
        promise.resolve( devices as! [BRPtouchDeviceInfo]);*/

        let option = BRLMNetworkSearchOption()
        option.searchDuration = 15
        let foundPrinters: NSMutableArray = []
        let result = BRLMPrinterSearcher.startNetworkSearch(option) { channel in
            let modelName = channel.extraInfo?.value(forKey: BRLMChannelExtraInfoKeyModelName) as? String ?? ""
            let ipaddress = channel.channelInfo
            let serialNumber = channel.extraInfo?.value(forKey: BRLMChannelExtraInfoKeySerialNumber) as? String ?? ""

            //create printerObject
            let printerObject: NSMutableDictionary = [:]
            printerObject["modelName"] = modelName
            printerObject["ipAddress"] = ipaddress
            printerObject["serialNumber"] = serialNumber
            printerObject["channelData"] = channel
            printerObject["type"] = "wifi"
            foundPrinters.add(printerObject)
        }
        promise.resolve(foundPrinters)
      #endif 
    }



    AsyncFunction("startSearchBluetoothPrinter") { (promise: Promise) in
      #if targetEnvironment(simulator)
        promise.resolve("Cannot find printers via bluetooth when using a simulator.");    
      #else
        /* Commenting prev code for now
        
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
        promise.resolve(foundPrinters);*/

        let option = BRLMBLESearchOption()
        option.searchDuration = 15
        let foundPrinters: NSMutableArray = []
        let result = BRLMPrinterSearcher.startBLESearch(option) { channel in
            let modelName = channel.extraInfo?.value(forKey: BRLMChannelExtraInfoKeyModelName) as? String ?? ""
            let advertiseLocalName = channel.channelInfo
            let serialNumber = channel.extraInfo?.value(forKey: BRLMChannelExtraInfoKeySerialNumber) as? String ?? ""
            print("Model : \(modelName), AdvertiseLocalName: \(advertiseLocalName)")

            let printerObject: NSMutableDictionary = [:]
            printerObject["modelName"] = modelName
            printerObject["advertiseLocalName"] = advertiseLocalName
            printerObject["serialNumber"] = serialNumber
            printerObject["channelData"] = channel
            printerObject["type"] = "bluetooth"
            foundPrinters.add(printerObject)
        }
        promise.resolve(foundPrinters);
      #endif 
    }

    // AsyncFunction("printSamplePDF") {( modelName: String, ipAddress: String, serialNumber: String, printerType: String, promise: Promise) in
    //     #if targetEnvironment(simulator)
    //       guard
    //           let url = Bundle.main.url(forResource: "samplepdf2", withExtension: "pdf")
    //           else {
    //               promise.resolve("Error - PDF file is not found.")
    //               return
    //         }
    //       promise.resolve("Cant print pdf \(url)");    
    //     #else

    //       var channel = BRLMChannel(initWithBluetoothSerialNumber: serialNumber)
    //       if (printerType == "wifi") {
    //         channel = BRLMChannel(wifiIPAddress: ipAddress) 
    //       } 
          

    //       let generateResult = BRLMPrinterDriverGenerator.open(channel)
    //       guard generateResult.error.code == BRLMOpenChannelErrorCode.noError,
    //           let printerDriver = generateResult.driver else {
    //             promise.resolve("Error - Open Channel: \(generateResult.error.code)")
    //             return
    //           }
    //       defer {
    //           printerDriver.closeChannel()
    //       }

    //       // Set your paper information
    //       let customPaperSize = BRLMCustomPaperSize(
    //         dieCutWithTapeWidth: CGFloat(4),
    //                               tapeLength: CGFloat(6),
    //                               margins: BRLMCustomPaperSizeMargins(top: 0.12, left: 0.06, bottom: 0.12, right: 0.06),
    //                               gapLength: CGFloat(0.125),
    //                               unitOfLength:  BRLMCustomPaperSizeLengthUnit.inch
    //                           )

    //       guard
    //           let url = Bundle.main.url(forResource: "samplepdf2", withExtension: "pdf")
    //           else {
    //               promise.resolve("Error - PDF file is not found.")
    //               return
    //         }

    //       //hardcoded settings for certain models for now, will make it dynamic maybe later if this is working?
    //       var printSettings = BRLMRJPrintSettings(defaultPrintSettingsWith: BRLMPrinterModel.QL_1110NWB)

    //       if (modelName == "RJ-4230B") {
    //         printSettings = BRLMRJPrintSettings(defaultPrintSettingsWith: BRLMPrinterModel.RJ_4230B)
    //       } else if (modelName == "TD-4550DNWB") {
    //         printSettings = BRLMRJPrintSettings(defaultPrintSettingsWith: BRLMPrinterModel.TD_4550DNWB)
    //       }

    //       printSettings.customPaperSize = customPaperSize
    //       let printError = printerDriver.printPDF(with: url!, settings: printSettings)
          
    //       if printError.code != .noError {
    //           promise.resolve("Error - Print PDF: \(printError.code)")
    //       }
    //       else {
    //           promise.resolve("Success - Print PDF")
    //       }
    //     #endif 
    //   }
    }
}

