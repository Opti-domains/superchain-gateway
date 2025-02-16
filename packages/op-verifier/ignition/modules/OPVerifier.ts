// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OPVerifierModule = buildModule("OPVerifierModule", (m) => {
  const gatewayURLs = m.getParameter("gatewayURLs", ["http://127.0.0.1:8080"]);
  const maxAge = m.getParameter("maxAge", 1296000); // 15 days

  const opVerifier = m.contract("OPVerifier", [gatewayURLs, maxAge]);

  return { opVerifier };
});

export default OPVerifierModule;
