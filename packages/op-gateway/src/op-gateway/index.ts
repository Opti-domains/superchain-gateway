import { EVMGateway } from "../evm-gateway";
import { JsonRpcProvider } from "ethers";
import { OPProofService, type OPProvableBlock } from "./OPProofService.js";

export type OPGateway = EVMGateway<OPProvableBlock>;

export async function makeOPGateway(l1providerUrl: string): Promise<OPGateway> {
  const l1Provider = new JsonRpcProvider(l1providerUrl);
  return new EVMGateway(await new OPProofService(l1Provider));
}

export { OPProofService, type OPProvableBlock };
