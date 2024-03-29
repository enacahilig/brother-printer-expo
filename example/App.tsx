import { Picker } from "@react-native-picker/picker";
import * as BrotherPrint from "brother-print";
import * as Network from 'expo-network';
import React, { useState } from "react";
import {
  StyleSheet,
  Text,
  View,
  Button,
  SafeAreaView,
  StatusBar,
  ScrollView,
  useColorScheme,
} from "react-native";
import { Colors } from "react-native/Libraries/NewAppScreen";
import generateLabel from "./helpers/generateLabel";
import * as FileSystem from 'expo-file-system';

export default function App() {
  const isDarkMode = useColorScheme() === "dark";

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  //Debugging
  const [networkState, setNetworkState] = useState<any>(null);

  const [printers, setPrinters] = useState<any[]>([]);
  const [printerMessage, setPrinterMessage] = useState("");
  const [selectedPrinter, setSelectedPrinter] = useState({
    modelName: "",
    serialNumber: "",
    printerName: "",
    ipAddress: "",
    type: "",
  });
  const [selectedPrinterIndex, setSelectedPrinterIndex] = useState(-1);

  const onFindPrinterViaWifi = async () => {
    const printersArray = await BrotherPrint.startSearchWiFiPrinter();
    console.log('printersArray', printersArray)
    if (Array.isArray(printersArray)) {
      setPrinters(printersArray);
    } else {
      setPrinterMessage(printersArray);
    }
  };



  const onFindPrinterViaBluetooth = async () => {
    console.log('onFindPrinterViaBluetooth')
    const printersArray = await BrotherPrint.startSearchBluetoothPrinter();
    console.log('printersArray', printersArray)
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

  const getNetworkState = async () => {
    setNetworkState(await Network.getNetworkStateAsync());
    console.log('networkState', networkState)
  }

  const onTestPrint = async () => {


    const testingContainer = {
      BarCode: "1234563789",
      ContractorNameText: "Test Test Text Text",
      DeckText: "Deck TExt ",
      FwdMidAftText: " FWd Aft Text",
      LoadingDateText: "Test Loading Text",
      Multiples: "1",
      PoNumberText: "PO Num Text",
      PrintedByText: "PrintedbyText",
      QRCodeURL: "http://dent.ly",
      SideText: "Side text Text",
      ShipmentID: "Shipment 1234",
      Description: "Description or Ipsum", //essentially the ContainerNum everything to the left of the "_"
      ContainerTypeName: "Export",
    }

    // alert('onTestPrint');
    if (selectedPrinter) {
      console.log('selectedPrinter', selectedPrinter);
      // alert(JSON.stringify(selectedPrinter));
      //return; //uncomment this line when testing and you want to conserve label paper by not printing

     try {


      const labelPDF = await generateLabel([
        testingContainer,
      ]);
      console.log('labelPDF', labelPDF)

      const results = await FileSystem.getInfoAsync(FileSystem.bundleDirectory+'/assets/samplepdf2.pdf');
      console.log('results', results)
      
      await BrotherPrint.printSamplePDF(
        selectedPrinter.modelName,
        selectedPrinter.ipAddress,
        selectedPrinter.serialNumber,
        selectedPrinter.type,
        labelPDF.filePath
      );

      // alert(`Printing response: ${status}`);
      // console.log('status', status);

     } catch (error) {
      console.log('error w/ generating label', error)
     }


      
    } else {
      alert(`Please select a printer.`);
    }
  };

  const renderPrinterList = () => {
    return printers.map((printer, index) => {
      return (
        <Picker.Item label={printer.modelName} value={index} key={index} />
      );
    });
  };


  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? "light-content" : "dark-content"}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}
      >
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
          <View style={styles.container}>
            <Picker
              selectedValue={selectedPrinterIndex}
              mode="dropdown"
              onValueChange={(itemValue, itemIndex) => {
                //console.log('selected printer', printers[itemValue]);
                setSelectedPrinter(printers[itemValue]);
                setSelectedPrinterIndex(itemValue);
              }}
            >
              <Picker.Item label="Select Printer" value={-1} key={-1} />
              {renderPrinterList()}
            </Picker>
          </View>
          <View style={styles.buttonContainer}>
            <Button
              onPress={() => onTestPrint()}
              title="Print Sample PDF"
              color="white"
            />
          </View>
          <Text>{printerMessage}</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: "600",
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: "400",
  },
  highlight: {
    fontWeight: "700",
  },
  buttonContainer: {
    margin: 20,
    backgroundColor: "#3796f4",
    padding: 10,
    borderRadius: 10,
  },
  container: {
    flex: 1,
    justifyContent: "center",
  },
});