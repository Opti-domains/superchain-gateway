// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SingularL1ResolverFixModule = buildModule(
  "SingularL1ResolverFixModule",
  (m) => {
    const registry = m.getParameter(
      "registry",
      "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"
    ); // ENS Registry

    // Deploy implementation
    const implementation = m.contract("SingularL1Resolver", [registry], {
      id: "SingularL1ResolverImpl",
    });

    return {
      implementation,
    };
  }
);

export default SingularL1ResolverFixModule;
