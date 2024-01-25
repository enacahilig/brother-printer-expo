import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { BrotherPrintViewProps } from './BrotherPrint.types';

const NativeView: React.ComponentType<BrotherPrintViewProps> =
  requireNativeViewManager('BrotherPrint');

export default function BrotherPrintView(props: BrotherPrintViewProps) {
  return <NativeView {...props} />;
}
