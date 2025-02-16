// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import OPVerifierModule from "./OPVerifier";

const TestL1Module = buildModule("TestL1Module", (m) => {
  const target = m.getParameter(
    "target",
    "0xFaC1E6fc6996ef8cdd39E3B29C477C68D3f50d69"
  );
  const portal = m.getParameter(
    "portal",
    "0x16Fc5058F25648194471939df75CF27A2fdC48BC"
  );
  const minAge = m.getParameter("minAge", 3600);

  const { opVerifier } = m.useModule(OPVerifierModule);

  const testL1 = m.contract("TestL1", [opVerifier, target, portal, minAge]);

  return { testL1 };
});

export default TestL1Module;
