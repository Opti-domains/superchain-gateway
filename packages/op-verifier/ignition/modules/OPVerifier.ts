// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OPVerifierModule = buildModule("OPVerifierModule", (m) => {
  const maxAge = m.getParameter("maxAge", 1296000); // 15 days

  const proxyAdminOwner = m.getParameter(
    "proxyAdminOwner",
    "0x8b6c27ec466923fad66Ada94c78AA320eA876969"
  );

  const opVerifierImpl = m.contract("OPVerifier", [maxAge], {
    id: "OPVerifierImpl",
  });

  const proxy = m.contract("TransparentUpgradeableProxy", [
    opVerifierImpl,
    proxyAdminOwner,
    "0x",
  ]);

  const proxyAdminAddress = m.readEventArgument(
    proxy,
    "AdminChanged",
    "newAdmin"
  );

  const opVerifier = m.contractAt("OPVerifier", proxy);

  const proxyAdmin = m.contractAt("ProxyAdmin", proxyAdminAddress);

  return { opVerifier, opVerifierImpl, proxyAdmin };
});

export default OPVerifierModule;
