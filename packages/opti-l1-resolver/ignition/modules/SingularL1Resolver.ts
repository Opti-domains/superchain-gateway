// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SingularL1ResolverModule = buildModule(
  "SingularL1ResolverModule",
  (m) => {
    const registry = m.getParameter(
      "registry",
      "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"
    ); // ENS Registry
    const admin = m.getParameter(
      "admin",
      "0x8b6c27ec466923fad66Ada94c78AA320eA876969"
    ); // Admin address

    // Deploy implementation
    const implementation = m.contract("SingularL1Resolver", [registry], {
      id: "SingularL1ResolverImpl",
    });

    // Deploy transparent proxy
    const proxy = m.contract("TransparentUpgradeableProxy", [
      implementation,
      admin,
      "0x", // No initialization data needed
    ]);

    const proxyAdminAddress = m.readEventArgument(
      proxy,
      "AdminChanged",
      "newAdmin"
    );

    const singularL1Resolver = m.contractAt("SingularL1Resolver", proxy);

    const proxyAdmin = m.contractAt("ProxyAdmin", proxyAdminAddress);

    return {
      implementation,
      proxyAdmin,
      proxy,
      singularL1Resolver,
    };
  }
);

export default SingularL1ResolverModule;
