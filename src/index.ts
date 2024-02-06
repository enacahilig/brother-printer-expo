import BrotherPrint from "./BrotherPrintModule";

export function startSearchWiFiPrinter(): string {
  return BrotherPrint.startSearchWiFiPrinter();
}

export function startSearchBluetoothPrinter() {
  return BrotherPrint.startSearchBluetoothPrinter2();
}

export function printSamplePDF(
  modelName: string,
  ipAddress: string,
  serialNumber: string,
  printerType: string,
) {
  return BrotherPrint.printSamplePDF(
    modelName,
    ipAddress,
    serialNumber,
    printerType,
  );
}
