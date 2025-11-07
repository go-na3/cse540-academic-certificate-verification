#  Academic Certificate Verification System

A blockchain-based system to **issue, verify, and manage academic certificates** using **Ethereum (Sepolia testnet)** and **IPFS**.  
This repo contains the **draft smart contract**, its **public interface**, a **deployment script placeholder**, and the plan for a **React + Ethers.js** frontend.

---

##  Description

- **Problem:** Traditional certificate verification is slow and vulnerable to tampering.  
- **Solution:** Store certificate metadata (issuer, recipient, IPFS CID, file hash, status) **on-chain**, and store the PDF itself on **IPFS**.  
- **Who uses it:**
  - **Issuers (Universities):** issue, revoke, update certificates  
  - **Students:** view and share certificates  
  - **Verifiers (Employers):** independently confirm authenticity  

---

##  Repository Structure

```
├── contracts/
│   └── CertificateRegistry.sol        # Draft contract (placeholder)
│
├── interfaces/
│   └── ICertificateRegistry.sol       # Public interface (events + function signatures)
│
├── scripts/
│   └── deployment.sh                  # Placeholder for deployment automation
│
└── README.md
```

---

##  Dependencies / Setup

You can use **Remix** or a local **Hardhat** environment. Below is the typical Hardhat setup:

- **Node.js** v18+  
- **Hardhat** (if using local dev)  
- **MetaMask** on **Sepolia**  
- (Optional) **Alchemy/Infura** endpoint for Sepolia

Example Hardhat init (if you add Hardhat later):
```bash
npm init -y
npm install --save-dev hardhat
npx hardhat
```

---

## How to Use / Deploy

### Option A: Remix (quick)
1. Open **Remix** → create `ICertificateRegistry.sol` and `CertificateRegistry.sol` files.  
2. Set compiler to **0.8.19** and enable optimization.  
3. Deploy to **Sepolia** using MetaMask.  
4. Copy the **deployed address** for frontend integration.

### Option B: Hardhat (script-based)
The repo includes `scripts/deployment.sh` as a placeholder. A typical flow (once a `deploy.js` is added) would be:
```bash
npx hardhat compile
npx hardhat run --network sepolia scripts/deploy.js
```
After deployment, share the **contract address** (to be used later in the frontend’s `.env`).

> Incomplete details are acceptable at this stage — this README provides the core steps you’ll flesh out as you implement the deployment script and frontend.

---

## Draft Contract/Code

### `contracts/CertificateRegistry.sol`
```solidity
// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

// Placeholder for CertificateRegistry contract implementation
```
**High-level intent:**  
This contract will implement the certificate lifecycle using the interface below:
- **Issue** a certificate (issuer-only)
- **Revoke** a certificate (issuer-only / admin)
- **Update** certificate CID/hash on re-issue
- **Query** certificates by issuer/recipient/ID
- **Role-based access** (admin, issuer)

### `interfaces/ICertificateRegistry.sol` (Signatures & Events)
Public interface exposing the main events & functions the frontend will call.  
Below are the **actual signatures present** in this repo’s interface (draft):

#### Events
```solidity
event CertificateIssued(
    uint256 indexed certificateId,
    address indexed issuer,
    address indexed recipient,
    string cid,
    bytes32 dataHash
);

event CertificateRevoked(
    uint256 indexed certificateId,
    address indexed issuer,
    uint256 revokedAt
);

event CertificateUpdated(
    uint256 indexed certificateId,
    address indexed issuer,
    string newCid,
    bytes32 newDataHash
);

event IssuerAdded(address indexed account);
event IssuerRemoved(address indexed account);
```

#### Functions
```solidity
function addIssuer(address _issuerAddress) external;
function removeIssuer(address _issuerAddress) external;
function isIssuer(address _issuerAddress) external view returns (bool);
function isAdmin(address _adminAddress) external view returns (bool);

function issueCertificate(
    address recipient,
    string calldata cid,
    bytes32 dataHash,
    string calldata metadata
) external returns (uint256 certificateId);

function revokeCertificate(uint256 certificateId) external;

function certificatesOfIssuer(address issuer)
    external
    view
    returns (uint256[] memory);

function certificatesOfRecipient(address recipient)
    external
    view
    returns (uint256[] memory);

function totalCertificates() external view returns (uint256);
function exists(uint256 certificateId) external view returns (bool);
```

**High-level component comments (what each does):**
- **Role management (`addIssuer`, `removeIssuer`, `isIssuer`, `isAdmin`):**  
  Admin-controlled list of authorized issuers who can create/revoke certificates.
- **Issuance (`issueCertificate`)**:  
  Creates an immutable record linking `issuer → recipient → IPFS CID` and **SHA-256** file hash for tamper detection; emits `CertificateIssued`.
- **Revocation (`revokeCertificate`)**:  
  Marks a certificate as revoked; emits `CertificateRevoked`.
- **Update (planned, `updateCertificate`)**:  
  Allows issuer to update the stored `CID`/`hash` upon re-issuing; emits `CertificateUpdated`.
- **Queries (`certificatesOfIssuer`, `certificatesOfRecipient`, `totalCertificates`, `exists`)**:  
  Read functions to support UI dashboards and public verification.

---

## Frontend Plan

Planned stack:
- **React + Vite**, **Ethers.js v6**, **Pinata SDK** (IPFS), **TailwindCSS + DaisyUI**
- **Portals:** Issuer (issue/revoke/update), Student (my certificates), Verifier (public verify by ID)
- **Flow:**
  1) Upload PDF → IPFS (get CID)  
  2) SHA-256 hash locally  
  3) Call contract (`issueCertificate`)  
  4) Verifier fetches CID + hash on-chain, downloads file, re-computes hash, and checks revocation status

---

## Design & Security

- **Integrity:** Hash comparison (on-chain vs locally computed)  
- **Decentralization:** Ethereum (Sepolia) + IPFS  
- **RBAC:** Admin/Issuer separation for controlled issuance  
- **Auditability:** Events (`Issued`, `Revoked`, `Updated`) act as an on-chain audit log

---

## Future work

- Implement `CertificateRegistry.sol` per the interface  
- Add Hardhat config + `deploy.js` and wire `deployment.sh`  
- Push `frontend/` (React + Ethers.js) and integrate contract ABI/address  
- Optional: DID/VCs, NFT representation, multi-chain (Polygon/Base)

---

## License

MIT — free to use and modify with attribution.
