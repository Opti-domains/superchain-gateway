// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OPVerifierModule = buildModule("OPVerifierModule", (m) => {
  const gatewayURLs = m.getParameter("gatewayURLs", [
    "https://gateway-sepolia.opti.domains",
  ]);
  const maxAge = m.getParameter("maxAge", 1296000); // 15 days

  const proxyAdminOwner = m.getParameter(
    "proxyAdminOwner",
    "0x8b6c27ec466923fad66Ada94c78AA320eA876969"
  );

  const opVerifierImpl = m.contract("OPVerifier", [maxAge]);

  m.call(opVerifierImpl, "initialize", [gatewayURLs]);

  const data = m.encodeFunctionCall(opVerifierImpl, "initialize", [
    gatewayURLs,
  ]);

  const opVerifier = m.contract("TransparentUpgradeableProxy", [
    opVerifierImpl,
    proxyAdminOwner,
    data,
  ]);

  const proxyAdminAddress = m.readEventArgument(
    opVerifier,
    "AdminChanged",
    "newAdmin"
  );

  const proxyAdmin = m.contractAt("ProxyAdmin", proxyAdminAddress);

  return { opVerifier, opVerifierImpl, proxyAdmin };
});

export default OPVerifierModule;
