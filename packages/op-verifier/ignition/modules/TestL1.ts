// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import OPVerifierModule from "./OPVerifier";

const TestL1Module = buildModule("TestL1Module", (m) => {
  const target = m.getParameter(
    "target",
    "0xFF0303afA52aae7BBAFd5EED084aCfC3A2F78d02"
  );
  const portal = m.getParameter(
    "portal",
    "0xbEb5Fc579115071764c7423A4f12eDde41f106Ed"
  );
  const minAge = m.getParameter("minAge", 3600);

  const { opVerifier } = m.useModule(OPVerifierModule);

  const testL1 = m.contract("TestL1", [opVerifier, target, portal, minAge]);

  return { testL1 };
});

export default TestL1Module;
