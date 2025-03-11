// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import SingularL1ResolverModule from "./SingularL1Resolver";

const DevelopmentModule = buildModule("DevelopmentModule", (m) => {
  const resolver = m.useModule(SingularL1ResolverModule);
  const nameWrapper = m.getParameter(
    "nameWrapper",
    "0x0635513f179D50A207757E05759CbD106d7dFcE8"
  ); // Admin address
  const verifier = m.getParameter(
    "verifier",
    "0xACe5278f0bB6EeBEe4429C8bb9863066dA60d5Aa"
  ); // Admin address
  const resolverL2 = m.getParameter(
    "resolverL2",
    "0xF486bfD0fE7c136231052bC9DD7C4f57870c8Ef1"
  ); // Resolver on L2 address
  const verifierData = m.getParameter(
    "verifierData",
    "0x00000000000000000000000016fc5058f25648194471939df75cf27a2fdc48bc0000000000000000000000000000000000000000000000000000000000000e10"
  ); // Resolver on L2 address

  const call = m.encodeFunctionCall(
    resolver.singularL1Resolver,
    "setDefaultVerifierConfig",
    [
      nameWrapper,
      {
        verifier,
        resolver: resolverL2,
        verifierData,
      },
    ]
  );

  m.call(resolver.proxyAdmin, "upgradeAndCall", [
    resolver.proxy,
    resolver.implementation,
    call,
  ]);

  return {
    ...resolver,
  };
});

export default DevelopmentModule;
