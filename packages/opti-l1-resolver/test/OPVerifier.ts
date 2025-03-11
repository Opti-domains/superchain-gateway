import { expect } from "chai";
import { Contract, Provider, FetchRequest, JsonRpcProvider } from "ethers";
import { ethers } from "hardhat";
import SingularL1ResolverABI from "./SingularL1ResolverABI";

// const namehash =
//   "0x438bfe3fc990665148f8ac1638323ab84054a5c22a1ab61fe63cebc3040129cb";
const namehash =
  "0x0b650766745c7638780829ef431caadf19eb6045ac44cbdb9806c79cacbe4c89";

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

      target = new ethers.Contract(
        targetAddress,
        SingularL1ResolverABI,
        provider
      );
    });

    it("text", async () => {
      const result = await target.text(namehash, "email", {
        enableCcipRead: true,
      });
      // expect(Number(result)).to.equal(42);
      console.log(result);
    });

    it("addrBytes", async () => {
      const result = await target["addr(bytes32,uint256)"](namehash, 60, {
        enableCcipRead: true,
      });
      // expect(Number(result)).to.equal(42);
      console.log(result);
    });

    it("addr", async () => {
      const result = await target["addr(bytes32)"](namehash, {
        enableCcipRead: true,
      });
      // expect(Number(result)).to.equal(42);
      console.log(result);
    });

    it("contentHash", async () => {
      const result = await target.contenthash(namehash, {
        enableCcipRead: true,
      });
      // expect(Number(result)).to.equal(42);
      console.log(result);
    });

    it("using resolve for text", async () => {
      // Test text resolution
      const textData = ethers.concat([
        target.interface.encodeFunctionData("text", [namehash, "email"]),
      ]);
      const textResult = await target.resolve(
        ethers.toUtf8Bytes(""),
        textData,
        { enableCcipRead: true }
      );
      console.log("Text via resolve:", ethers.toUtf8String(textResult));
    });

    it("using resolve for addr", async () => {
      // Test addr resolution
      const addrData = ethers.concat([
        target.interface.encodeFunctionData("addr(bytes32)", [namehash]),
      ]);
      const addrResult = await target.resolve(
        ethers.toUtf8Bytes(""),
        addrData,
        { enableCcipRead: true }
      );
      console.log("Addr via resolve:", addrResult);
    });

    it("using resolve for contentHash", async () => {
      // Test contentHash resolution
      const contentHashData = ethers.concat([
        target.interface.encodeFunctionData("contenthash", [namehash]),
      ]);
      const contentHashResult = await target.resolve(
        ethers.toUtf8Bytes(""),
        contentHashData,
        { enableCcipRead: true }
      );
      console.log("ContentHash via resolve:", contentHashResult);
    });
  });
}

// setupTest(
//   "Mainnet",
//   "https://1rpc.io/eth",
//   "0x43eAfdB769638e9a9e4d0190eeAb39e805D00689"
// );
setupTest(
  "Sepolia",
  "https://1rpc.io/sepolia",
  "0x7BA8071B8AaD8E91C0eEA70D7cB6816699b1Cc72"
);
