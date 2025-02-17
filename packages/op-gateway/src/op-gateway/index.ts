import { EVMGateway } from "../evm-gateway";
import { JsonRpcProvider } from "ethers";
import { OPProofService, type OPProvableBlock } from "./OPProofService.js";

export type OPGateway = EVMGateway<OPProvableBlock>;

export async function makeOPGateway(
  l1providerUrl: string[]
): Promise<OPGateway> {
  return new EVMGateway(
    await new OPProofService(
      l1providerUrl.map((url) => new JsonRpcProvider(url))
    )
  );
}

export { OPProofService, type OPProvableBlock };
