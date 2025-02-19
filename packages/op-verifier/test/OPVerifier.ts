import { expect } from "chai";
import { Contract, Provider, FetchRequest, JsonRpcProvider } from "ethers";
import { ethers } from "hardhat";
import TestL1ABI from "./TestL1ABI";

function setupTest(network: string, rpc: string, targetAddress: string) {
  describe(`OPVerifier [${network}]`, () => {
    let provider: Provider;
    let target: Contract;

    before(async () => {
      // Hack to get a 'real' ethers provider from hardhat. The default `HardhatProvider`
      // doesn't support CCIP-read.
      provider = new JsonRpcProvider(rpc);

      // Replace ethers' fetch function with one that calls the gateway directly.
      const getUrl = FetchRequest.createGetUrlFunc();
      ethers.FetchRequest.registerGetUrl(async (req: FetchRequest) => {
        console.log(req.url);
        return getUrl(req);
      });

      target = new ethers.Contract(targetAddress, TestL1ABI, provider);
    });

    it("simple proofs for fixed values", async () => {
      const result = await target.getLatest({ enableCcipRead: true });
      expect(Number(result)).to.equal(42);
    });

    it("simple proofs for dynamic values", async () => {
      const result = await target.getName({ enableCcipRead: true });
      expect(result).to.equal("Satoshi");
    });

    it("nested proofs for dynamic values", async () => {
      const result = await target.getHighscorer(42, { enableCcipRead: true });
      expect(result).to.equal("Hal Finney");
    });

    it("nested proofs for long dynamic values", async () => {
      const result = await target.getHighscorer(1, { enableCcipRead: true });
      expect(result).to.equal(
        "Hubert Blaine Wolfeschlegelsteinhausenbergerdorff Sr."
      );
    });

    it("nested proofs with lookbehind", async () => {
      const result = await target.getLatestHighscore({ enableCcipRead: true });
      expect(Number(result)).to.equal(12345);
    });

    it("nested proofs with lookbehind for dynamic values", async () => {
      const result = await target.getLatestHighscorer({ enableCcipRead: true });
      expect(result).to.equal("Hal Finney");
    });

    it("mappings with variable-length keys", async () => {
      const result = await target.getNickname("Money Skeleton", {
        enableCcipRead: true,
      });
      expect(result).to.equal("Vitalik Buterin");
    });

    it("nested proofs of mappings with variable-length keys", async () => {
      const result = await target.getPrimaryNickname({ enableCcipRead: true });
      expect(result).to.equal("Hal Finney");
    });

    it("treats uninitialized storage elements as zeroes", async () => {
      const result = await target.getZero({ enableCcipRead: true });
      expect(Number(result)).to.equal(0);
    });

    it("treats uninitialized dynamic values as empty strings", async () => {
      const result = await target.getNickname("Santa", {
        enableCcipRead: true,
      });
      expect(result).to.equal("");
    });
  });
}

setupTest(
  "Mainnet",
  "https://1rpc.io/eth",
  "0x43eAfdB769638e9a9e4d0190eeAb39e805D00689"
);
setupTest(
  "Sepolia",
  "https://1rpc.io/sepolia",
  "0x5D184aDEB355FAa3b94f975CD17b82F5E63d1d3e"
);
