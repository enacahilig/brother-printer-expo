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

        let option = BRLMNetworkSearchOption()
        option.searchDuration = 15
        let foundPrinters: NSMutableArray = []
        let result = BRLMPrinterSearcher.startNetworkSearch(option) { channel in
            let modelName = channel.extraInfo?.value(forKey: BRLMChannelExtraInfoKeyModelName) as? String ?? ""
            let ipaddress = channel.channelInfo
            let serialNumber = channel.extraInfo?.value(forKey: BRLMChannelExtraInfoKeySerialNumber) as? String ?? ""
            print("modelName: \(modelName) ipaddress: \(ipaddress) serialNumber: \(serialNumber)")
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
            
        let foundPrinters: NSMutableArray = []
        let devices =  BRLMPrinterSearcher.startBluetoothSearch().channels;
        for channel in devices { 
            let modelName = channel.extraInfo?.value(forKey: BRLMChannelExtraInfoKeyModelName) as? String ?? ""
            let ipaddress = channel.channelInfo
            let serialNumber = channel.extraInfo?.value(forKey: BRLMChannelExtraInfoKeySerialNumber) as? String ?? ""
            print("modelName: \(modelName) ipaddress: \(ipaddress) serialNumber: \(serialNumber)")
  
            //create printerObject
            let printerObject: NSMutableDictionary = [:]
            printerObject["modelName"] = modelName
            printerObject["ipAddress"] = ipaddress
            printerObject["serialNumber"] = serialNumber
            printerObject["channelData"] = channel
            printerObject["type"] = "bluetooth"
            foundPrinters.add(printerObject)
        }
        promise.resolve(foundPrinters);
      #endif 
    }

    AsyncFunction("printSamplePDF") {( modelName: String, ipAddress: String, serialNumber: String, printerType: String, promise: Promise) in
        #if targetEnvironment(simulator)
          guard
              let url = Bundle.main.url(forResource: "samplepdf2", withExtension: "pdf")
              else {
                  promise.resolve("Error - PDF file is not found.")
                  return
            }
          promise.resolve("Cant print pdf \(url)");    
        #else

          let channel = BRLMChannel(bluetoothSerialNumber: serialNumber)

          let generateResult = BRLMPrinterDriverGenerator.open(channel)
          guard generateResult.error.code == BRLMOpenChannelErrorCode.noError,
              let printerDriver = generateResult.driver else {
                  promise.resolve("Error - Open Channel: \(generateResult.error.code)")
                  return
          }
          defer {
              printerDriver.closeChannel()
          }

          guard
              let url = Bundle.main.url(forResource: "samplepdf2", withExtension: "pdf"),
              let printSettings = BRLMTDPrintSettings(defaultPrintSettingsWith: BRLMPrinterModel.RJ_4230B)
              else {
                  promise.resolve("Error - PDF file is not found.")
                  return
          }

          // Set your paper information
          let margins = BRLMCustomPaperSizeMargins(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
          let customPaperSize = BRLMCustomPaperSize(rollWithTapeWidth: 2.0,
                                                      margins: margins,
                                                      unitOfLength: .inch)
          printSettings.customPaperSize = customPaperSize

          let printError = printerDriver.printPDF(with: url, settings: printSettings)

          if printError.code != .noError {
            promise.resolve("Error - Print Image: \(printError.code)")
          }
          else {
            promise.resolve("Success - Print Image")
          }
        #endif 
      }
    }
}

