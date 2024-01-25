import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to BrotherPrint.web.ts
// and on native platforms to BrotherPrint.ts
import BrotherPrintModule from './BrotherPrintModule';
import BrotherPrintView from './BrotherPrintView';
import { ChangeEventPayload, BrotherPrintViewProps } from './BrotherPrint.types';

// Get the native constant value.
export const PI = BrotherPrintModule.PI;

export function hello(): string {
  return BrotherPrintModule.hello();
}

export async function setValueAsync(value: string) {
  return await BrotherPrintModule.setValueAsync(value);
}

const emitter = new EventEmitter(BrotherPrintModule ?? NativeModulesProxy.BrotherPrint);

export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return emitter.addListener<ChangeEventPayload>('onChange', listener);
}

export { BrotherPrintView, BrotherPrintViewProps, ChangeEventPayload };
