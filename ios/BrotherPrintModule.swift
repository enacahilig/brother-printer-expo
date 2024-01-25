import ExpoModulesCore
import BRLMPrinterKit

public class BrotherPrintModule: Module {
  public func definition() -> ModuleDefinition {
    Name("BrotherPrint")

    Function("startSearchWiFiPrinter") { (_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void in
      let manager = BRPtouchNetworkManager();
      manager.startSearch(5);
      let devices = manager.getPrinterNetInfo()  as! [BRPtouchDeviceInfo];
      var printers = "";
      for deviceInfo in devices {
          if let deviceInfo = deviceInfo as? BRPtouchDeviceInfo {
              printers += deviceInfo.strModelName + " ";
          }
      }
      resolve(devices as! [BRPtouchDeviceInfo]);
    }

    Function("startSearchBluetoothPrinter") { (_ resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void in
     let devices = BRPtouchBluetoothManager.shared().pairedDevices()  as! [BRPtouchDeviceInfo]; //discover bluetooth printers

      let foundPrinters: NSMutableArray = []
      for deviceInfo in devices { //there should only be one
          if let deviceInfo = deviceInfo as? BRPtouchDeviceInfo {
            let printerObject: NSMutableDictionary = [:]
            printerObject["modelName"] = deviceInfo.strModelName
            printerObject["printerName"] = deviceInfo.strPrinterName
            printerObject["serialNumber"] = deviceInfo.strSerialNumber
            foundPrinters.add(printerObject)

            
            //for testing - simulate a 2nd printer
            /*let printerObject2: NSMutableDictionary = [:]
            printerObject2["modelName"] = deviceInfo.strModelName + " - simulated"
            printerObject2["printerName"] = deviceInfo.strPrinterName
            printerObject2["serialNumber"] = deviceInfo.strSerialNumber
            foundPrinters.add(printerObject2)
            */

          }
      }
      resolve(foundPrinters);
    }

    Function printDDLPDF (_ strModelName: String, strSerialNumber: String,  strPrinterName: String, strFilePath: String, resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) -> Void {
      let channel = BRLMChannel(bluetoothSerialNumber: strSerialNumber)
      
      let generateResult = BRLMPrinterDriverGenerator.open(channel)
      guard generateResult.error.code == BRLMOpenChannelErrorCode.noError,
            let printerDriver = generateResult.driver else {
        resolve("Error - Open Channel: \(generateResult.error.code)")
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

      
      let myUrlString = "file:///private/" + strFilePath
      let myUrl = URL(string: myUrlString)
      
      //we have to prep the BRLMPrinterModel and base that on the strModelName passed
      //brute force, but with the guard the printSettings weren't in scope, so I put it in both the if and else
      if (strModelName == "RJ-4230B") { //belt printer model that DDL uses
        guard
          let printSettings = BRLMRJPrintSettings(defaultPrintSettingsWith: BRLMPrinterModel.RJ_4230B)
        else {
          resolve("Error - PDF file is not found.")
          return
        }
        printSettings.customPaperSize = customPaperSize
        let printError = printerDriver.printPDF(with: myUrl!, settings: printSettings)
        
        if printError.code != .noError {
            resolve("Error - Print PDF: \(printError.code)")
        }
        else {
            resolve("Success - Print PDF")
        }
      }
      else { //default to desktop printer
        //this one uses BRLMTDPrintSettings instead of BRLMRJPrintSettings
        guard
          let printSettings = BRLMTDPrintSettings(defaultPrintSettingsWith: BRLMPrinterModel.TD_4550DNWB)
        else {
          resolve("Error - PDF file is not found.")
          return
        }
        printSettings.customPaperSize = customPaperSize
        let printError = printerDriver.printPDF(with: myUrl!, settings: printSettings)
        
        if printError.code != .noError {
            resolve("Error - Print PDF: \(printError.code)")
        }
        else {
            resolve("Success - Print PDF")
        }
      }
      
    }
  }
}