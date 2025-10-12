export interface IMoped {
  wheels: number;
  engineDisplacement: number;

  countWheels: () => number;
  getEngineDisplacement: () => number;
}

export type ConvertOptions = string;
export type OptimizationOptions = number;
