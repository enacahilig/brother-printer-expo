import BrotherPrint from "./BrotherPrintModule";

export function startSearchWiFiPrinter(): string {
  return BrotherPrint.startSearchWiFiPrinter();
}

export function startSearchBluetoothPrinter() {
  return BrotherPrint.startSearchBluetoothPrinter();
}

export function printSamplePDF(
  strModelName: string,
  strSerialNumber: string,
  strPrinterName: string,
) {
  return BrotherPrint.printSamplePDF(
    strModelName,
    strSerialNumber,
    strPrinterName,
  );
}