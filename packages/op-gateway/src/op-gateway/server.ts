import { Command } from "@commander-js/extra-typings";
import { EVMGateway } from "../evm-gateway";
import { JsonRpcProvider } from "ethers";
import { OPProofService } from "./OPProofService.js";
import { ServerLambda } from "../ccip-router/AWSLambdaCCIPRouter";
import express from "express";
import cors from "cors";
import type { Request, Response } from "express";
import { RequestContext } from "generic-rest-api-router";

const program = new Command()
  .option("-p, --port <port>", "port to listen on", "8080")
  .option(
    "-u, --l1-provider-url <url>",
    "l1 provider url",
    "https://rpc.ankr.com/eth"
  )
  .option("--l1-provider-url-2 <url>", "secondary l1 provider url")
  .option("--l1-provider-url-3 <url>", "tertiary l1 provider url");

program.parse();

(async () => {
  const options = program.opts();

  const providers = [new JsonRpcProvider(options.l1ProviderUrl)];

  if (options.l1ProviderUrl2) {
    providers.push(new JsonRpcProvider(options.l1ProviderUrl2));
  }

  if (options.l1ProviderUrl3) {
    providers.push(new JsonRpcProvider(options.l1ProviderUrl3));
  }

  const gateway = new EVMGateway(new OPProofService(providers));
  const server = new ServerLambda();
  gateway.add(server);

  const lambdaApp = server.makeApp("");
  const expressApp = express();

  expressApp.use(cors());
  expressApp.use(express.json());

  // Forward all requests to lambda handler
  expressApp.all("*", async (req: Request, res: Response) => {
    const context: RequestContext = {
      getBody: () => JSON.stringify(req.body),
      getHttpMethod: () => req.method,
      getPath: () => req.path,
    };

    const result = await lambdaApp.handle(context);
    res
      .status(result.statusCode)
      .set(result.headers || {})
      .send(result.body);
  });

  const port = parseInt(options.port);
  if (String(port) !== options.port) throw new Error("Invalid port");

  expressApp.listen(port, function () {
    console.log(`Listening on ${port}`);
  });
})();
