export interface IMoped {
  wheels: number;
  engineDisplacement: number;

  countWheels: () => number;
  getEngineDisplacement: () => number;
}
