## OP Gateway

A CCIP gateway connecting ENS names on the Superchain to ENS on Ethereum.

## Running the gateway

```bash
pnpm start -p 8080 -u https://your-l1-provider.com --l1-provider-url-2 https://backup-provider.com
```

Available options:
- `-p, --port`: Port to listen on (default: 8080)
- `-u, --l1-provider-url`: Primary L1 provider URL (default: https://rpc.ankr.com/eth)
- `--l1-provider-url-2`: Secondary L1 provider URL (optional)
- `--l1-provider-url-3`: Tertiary L1 provider URL (optional)