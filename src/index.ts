import BrotherPrint from "./BrotherPrintModule";

export function startSearchWiFiPrinter(): string {
  console.log('startSearchWiFiPrinter')
  return BrotherPrint.startSearchWiFiPrinter();
}

export function startSearchBluetoothPrinter() {
  console.log('startSearchBluetoothPrinter')
  return BrotherPrint.startSearchBluetoothPrinter();
}

export function printSamplePDF(
  modelName: string,
  ipAddress: string,
  serialNumber: string,
  printerType: string,
  strFilePath: string,
) {
  return BrotherPrint.printSamplePDF(
    modelName,
    ipAddress,
    serialNumber,
    printerType,
    strFilePath,
  );
}
