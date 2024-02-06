import  RNBarcode from 'react-native-barcode-zxing';

export const generateQrCode = async (code: string): Promise<string> => {
    const barcodeOptions = {
      type: 'qrcode',
      width: 300,
      height: 300,
      code,
    };
    return new Promise((resolve, reject) => {
      RNBarcode.encode(barcodeOptions, (err: any, blob: any) => {
        if (err) {
          console.error(err);
          return reject(err);
        } else {
          let baseImg = `data:image/png;base64,${blob}`;
          return resolve(baseImg);
        }
      });
    });
  };
