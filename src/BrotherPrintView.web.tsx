import * as React from 'react';

import { BrotherPrintViewProps } from './BrotherPrint.types';

export default function BrotherPrintView(props: BrotherPrintViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
