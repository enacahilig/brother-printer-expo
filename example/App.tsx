import * as BrotherPrint from "brother-print";
import React, { useState } from "react";
import { StyleSheet, Text, View, Button } from "react-native";

export default function App() {
  const [printers, setPrinters] = useState<any[]>([]);
  const [printerMessage, setPrinterMessage] = useState("");

  const onFindPrinterViaWifi = async () => {
    const printersArray = await BrotherPrint.startSearchWiFiPrinter();
    if (Array.isArray(printersArray)) {
      setPrinters(printersArray);
    } else {
      setPrinterMessage(printersArray);
    }
  };

  const onFindPrinterViaBluetooth = async () => {
    const printersArray = await BrotherPrint.startSearchBluetoothPrinter();
    if (Array.isArray(printersArray)) {
      setPrinters(printersArray);
    } else {
      setPrinterMessage(printersArray);
    }
  };

  const displayPrinters = () => {
    return printers.map((printer, index) => {
      return <Text> {printer.modelName} </Text>;
    });
  };

  return (
    <View style={styles.container}>
      <View style={styles.buttonContainer}>
        <Button
          onPress={() => onFindPrinterViaWifi()}
          title="Find Printers via Wifi"
          color="white"
        />
      </View>
      <View style={styles.buttonContainer}>
        <Button
          onPress={() => onFindPrinterViaBluetooth()}
          title="Find Printers via Bluetooth"
          color="white"
        />
      </View>
      <Text>{displayPrinters()}</Text>
      <Text>{printerMessage}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
  buttonContainer: {
    margin: 20,
    backgroundColor: "#3796f4",
    padding: 10,
    borderRadius: 10,
  },
});
