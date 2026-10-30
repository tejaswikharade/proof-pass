# ProofPass

An issuer-managed, on-chain registry for verifiable credentials. ProofPass records only a credential hash and verification state on-chain—never the underlying document.

## What it does

- Registry owner authorizes or removes trusted issuers
- Issuers create a credential for a wallet address and document hash
- Original issuer or owner can revoke a credential
- Anyone can look up a hash and verify whether it remains valid

## Quick start

```bash
forge test
cd web && npm install && npm run dev
```

## Architecture

`ProofPass.sol` is deliberately small: credentials are keyed by `bytes32` digest and hold a subject, issuer, URI, issue time, and optional revocation time. Use a salted hash of the off-chain credential to avoid exposing private data.

> This is an educational reference implementation, not an audited production registry.
