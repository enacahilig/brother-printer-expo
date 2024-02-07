/* @flow */
import {generateBarCode, generateQrCode} from './generateQRCode';

import RNHTMLtoPDF from 'react-native-html-to-pdf';
// import Promise from 'react-native/Libraries/Promise';
import {chunk} from 'lodash';
import ddlLogo from '../assets/DDL_Logo_bottom_text.js';

interface ContainerItem {
  BarCode: string | null;
  ContractorNameText: string | null;
  DeckText: string | null;
  FwdMidAftText: string | null;
  LoadingDateText: string | null;
  Multiples?: string | null;
  PoNumberText: string | null;
  PrintedByText: string | null;
  QRCodeURL?: string;
  SideText: string | null;
  ShipmentID: string | null;
  Description: string | null; //essentially the ContainerNum everything to the left of the "_"
  ContainerTypeName: string | null;
}

interface LabelItem extends ContainerItem {
  qrCodeImage: string;
  barcodeImage: string;
}

export default async (items: Array<ContainerItem>): Promise<any> => {
    try {
        const _items = await Promise.all(items.map(item => getItemWithQrImg(item)));
        const chunks = chunk(_items, 2);
        const options = {
            html: generateLabelHTML(_items),
            directory: 'Documents',
        };
        return RNHTMLtoPDF.convert(options);
    } catch (err) {
        console.error('generate label pdf error:', err);
    }
};

const getItemWithQrImg = async (item: ContainerItem): Promise<LabelItem> => {
  const qrCodeImage = await generateQrCode(item?.QRCodeURL || item.BarCode || '');
  const barcodeImage = await generateBarCode(item.BarCode || '');
  return {...item, qrCodeImage, barcodeImage};
};
/*----------------------------------------------------------------
w: 21cm, h: 27.2cm and page 26m for height
*/
const generateLabelHTML = (items: Array<LabelItem>) => /* html */ `
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <style type="text/css">
      body {
        width: 21cm; 15.24cm;
        height: 27.2cm; 10.162cm;

        /* change the margins as you want them to be. */
        /* to centre page on screen*/

      }
      .page {
        height: 26cm; //10.162cm;
        clear: both;
        page-break-after: always;
      }
      .active {
        border: 5px solid;
        padding: 7px;
        border-radius: 10px;
      }

      strong {
  	font-weight:bold;
  	font-size:32px; 
      }

    </style>
  </head>
  <body>
    ${items.map(
            ({
              BarCode,
              ContractorNameText,
              DeckText,
              FwdMidAftText,
              LoadingDateText,
              Multiples,
              PoNumberText,
              PrintedBy,
              SideText,
              qrCodeImage,
              barcodeImage,
              PrintedDate,
              ShipmentID,
              Description,
              ContainerTypeName
            }, index) => /* html */ `
            <div
          class="page"
        >
          <!-- <p>page: ${index + 1}</p> -->
              <div style="border-collapse: collapse;width: 10in;overflow: hidden;height: 8in;border: 1px solid; transform: rotate(90deg); margin-top: 1.2in; margin-left: -0.8in; position: absolute;">
                <div style="display: flex; border-bottom: 1px solid;">
                  <div style="width: 215px;height: 225px;text-align: center;border-right: 1px solid;display: flex;align-items: center;">
                    <img src="${ddlLogo}" width="188" height="205" style="padding: 0 14px;">
                  </div> 
                  <div style="width: 100%;text-align: center;vertical-align: top;display: flex;flex-direction: row;justify-content: space-around;" colspan="2">
                    <div style="display: flex;flex-direction: column;justify-content: center;align-items: center;padding: 0 40px;">
                      <img src="${barcodeImage}" width="310" height="155" style="margin-top: 10px;">
                      <div style="text-align: center;font-size: 40px;margin-top: 10px;">${BarCode}</div>
                    </div>
                    <div style="display: flex;justify-content: center;align-items: center;padding: 0 15px;">
                      <img src="${qrCodeImage}" width="190" height="190">
                    </div>
                  </div>
                </div>
                <div style="display: flex; border-bottom: 1px solid;">
                                      <div style="width: 2.8in;border-right: 1px solid;display: flex;align-items: center;justify-content: center;"><strong>CONTRACTOR</strong></div>
                                      <div style="width: 3.7in;border-right: 1px solid;display: flex;align-items: center;justify-content: center; overflow: hidden;">
                                        <strong style="padding: 5px;">${
                                          !!ContractorNameText
                                            ? ContractorNameText
                                            : ''
                                        }</strong>
                                      </div>
                                      <div style="width: 2.5in;height: 96px;display: flex;flex-direction: column;align-items: center; overflow: hidden;">
                                      <strong style="
                          zzzfont-size: 11px;
                          margin-top: 2px;
                      ">QTY</strong> <strong style="
                          display: flex;
                          zzzfont-size: 16px;
                          padding: 5px;
                      ">${
                        !!Multiples ? Multiples : 1
                      }</strong>                </div>
                                    </div>
                                    <div style="
                                    display: flex;
                                    border-bottom: 1px solid;
                                    height: 90px;
                                ">
                                                <div style="width: 2in;border-right: 1px solid;display: flex;align-items: center;justify-content: center;"><strong>PO#</strong></div>
                                                <div style="width: calc(3.5in - 1px);border-right: 1px solid;display: flex;align-items: center;justify-content: center; overflow: hidden;">
                                                  <strong style="padding: 5px;">${
                                                    !!PoNumberText
                                                      ? PoNumberText
                                                      : ''
                                                  }</strong>
                                                </div>
                                                
                                    <div style="width: 2in;border-right: 1px solid;display: flex;justify-content: center;align-items: center;">
                                                <strong>LP DATE:</strong>                 </div><div style="width: 2.5in;display: flex;justify-content: center;align-items: center; overflow: hidden;">
                                                  <strong style="
                                    display: flex;
                                    zzzfont-size: 16px;
                                    padding: 5px;
                                ">${
                                  !!LoadingDateText ? LoadingDateText : ''
                                }</strong>                </div>
                                              </div>
 
                                <div style="
                                    display: flex;
                                    border-bottom: 1px solid;
                                    height: 108px;
                                ">
                                                <div style="width: 3in;border-right: 1px solid;display: flex;align-items: center;justify-content: center;"><strong>DECK #:</strong></div>
                                                <div style="width: 3in;border-right: 1px solid;display: flex;align-items: center;justify-content: center; overflow: hidden;">
                                                  <strong style="padding: 5px;">${
                                                    !!DeckText ? DeckText.replace(/Deck /i,"").replace(/Marshalling Area/gi,"M.A.") : ''
                                                  }</strong>
                                                </div>
                                                
                                    <div style="
                                    width: calc(2in - 1px);
                                    border-right: 1px solid;
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    ">
                                    <strong style="padding: 5px;">${
                                        !!FwdMidAftText ? FwdMidAftText.toUpperCase() : ''
                                        }</strong>       
                                    </div>
                                    <div style="
                                    width: 2in;
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    ">
                                        <strong style="padding: 5px;">${
                                            !!SideText ? SideText.replace(/Starboard/gi,"STBD").toUpperCase() : ''
                                            }</strong>
                                    </div>
                                </div>

                            <div style="
                                display: flex;
                                border-bottom: 1px solid;
                                height: 120px;
                            ">
                                <div style="width: 3in;border-right: 1px solid;display: flex;align-items: center;justify-content: center;"><strong>SHIPPING ID:</strong></div>
                                <div style="width: calc(7in - 1px);border-right: 1px solid;display: flex;align-items: center;justify-content: center; overflow: hidden;">
                                    <strong style="padding: 7px;">${
                                    !!ShipmentID ? ShipmentID.toUpperCase() : ''
                                    }</strong>
                                </div>


                            </div>


                            <div style="
                                    display: flex;
                                    height: 62px;
                                    border-bottom: 1px solid;
                                ">
                                                <div style="width: 8in;border-right: 1px solid;display: flex;align-items: center;justify-content: start ; overflow: hidden; white-space:nowrap;">
                                                  <strong style="padding: 5px;">${
                                                    !!Description
                                                      ? Description
                                                      : ''
                                                  }</strong>
                                                </div>
                                                
                                    <div style="
                                    width: 2in;
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    
                                    ">
                                                <strong style="padding: 5px;">${
                                                  !!ContainerTypeName ? ContainerTypeName : ''
                                                }</strong>
                                    </div>
                            </div>


                            <!-- new -->
                            <div style="
                                    display: flex;
                                    height: 62px;
                                ">
                                                <div style="width: 1in;border-right: 1px solid;display: flex;align-items: center;justify-content: center;"><strong>BY</strong></div>
                                                <div style="width: 5in;border-right: 1px solid;display: flex;align-items: center;justify-content: center; overflow: hidden;line-break: anywhere;">
                                                  <strong style="padding: 5px;">${
                                                    !!PrintedBy
                                                      ? PrintedBy
                                                      : ''
                                                  }</strong>
                                                </div>

                                    <div style="
                                    width: calc(2in - 1px);
                                    border-right: 1px solid;
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    ">
                                                <strong style="
                                ">DATE</strong>
                                    </div><div style="
                                    width: 2in;
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    ">
                                                <strong style="padding: 5px;">${
                                                  !!PrintedDate ? PrintedDate : ''
                                                }</strong>
                                    </div>
                            </div>



                </div>
                </div>   
              `,)
      .join('')}
  </body>
</html>
`;
