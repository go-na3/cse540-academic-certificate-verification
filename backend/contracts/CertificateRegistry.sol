// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interfaces/ICertificateRegistry.sol";

/**
 * @title CertificateRegistry
 * @notice Implementation of the Academic Certificate Verification System.
 * @dev Implements ICertificateRegistry interface using AccessControl for RBAC.
 */
contract CertificateRegistry is ICertificateRegistry, AccessControl {
    // ------------------------------------------------------------------------
    // Roles
    // ------------------------------------------------------------------------
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    // ------------------------------------------------------------------------
    // Storage
    // ------------------------------------------------------------------------
    uint256 private _nextCertificateId = 1;

    struct Certificate {
        uint256 id;
        address issuer;
        address recipient;
        string cid;
        bytes32 dataHash;
        uint256 issuedAt;
        bool revoked;
        uint256 revokedAt;
        string metadata;
    }

    mapping(uint256 => Certificate) private certificates;
    mapping(address => uint256[]) private issuedCertificates;
    mapping(address => uint256[]) private recipientCertificates;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(address admin) {
        require(admin != address(0), "Invalid admin address");
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ISSUER_ROLE, admin);
    }

    // ------------------------------------------------------------------------
    // Role-Based Access Control
    // ------------------------------------------------------------------------
    function addIssuer(address _issuerAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_issuerAddress != address(0), "Invalid issuer address");
        _grantRole(ISSUER_ROLE, _issuerAddress);
        emit IssuerAdded(_issuerAddress);
    }

    function removeIssuer(address _issuerAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(hasRole(ISSUER_ROLE, _issuerAddress), "Not an issuer");
        _revokeRole(ISSUER_ROLE, _issuerAddress);
        emit IssuerRemoved(_issuerAddress);
    }

    function isIssuer(address _issuerAddress) external view returns (bool) {
        return hasRole(ISSUER_ROLE, _issuerAddress);
    }

    function isAdmin(address _adminAddress) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _adminAddress);
    }

    // ------------------------------------------------------------------------
    // Certificate Functions
    // ------------------------------------------------------------------------
    function issueCertificate(
        address recipient,
        string calldata cid,
        bytes32 dataHash,
        string calldata metadata
    ) external onlyRole(ISSUER_ROLE) returns (uint256 certificateId) {
        require(recipient != address(0), "Invalid recipient address");
        require(bytes(cid).length > 0, "CID required");
        require(dataHash != bytes32(0), "Invalid data hash");

        certificateId = _nextCertificateId++;
        certificates[certificateId] = Certificate({
            id: certificateId,
            issuer: msg.sender,
            recipient: recipient,
            cid: cid,
            dataHash: dataHash,
            issuedAt: block.timestamp,
            revoked: false,
            revokedAt: 0,
            metadata: metadata
        });

        issuedCertificates[msg.sender].push(certificateId);
        recipientCertificates[recipient].push(certificateId);

        emit CertificateIssued(certificateId, msg.sender, recipient, cid, dataHash);
        return certificateId;
    }

    function revokeCertificate(uint256 certificateId) external {
        Certificate storage cert = certificates[certificateId];
        require(cert.id != 0, "Certificate not found");
        require(!cert.revoked, "Already revoked");
        require(
            msg.sender == cert.issuer || hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Unauthorized revocation"
        );

        cert.revoked = true;
        cert.revokedAt = block.timestamp;

        emit CertificateRevoked(certificateId, msg.sender, cert.revokedAt);
    }

    function updateCertificate(
        uint256 certificateId,
        string calldata newCid,
        bytes32 newDataHash
    ) external {
        Certificate storage cert = certificates[certificateId];
        require(cert.id != 0, "Certificate not found");
        require(!cert.revoked, "Cannot update revoked certificate");
        require(
            msg.sender == cert.issuer || hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Unauthorized update"
        );
        require(bytes(newCid).length > 0, "CID required");
        require(newDataHash != bytes32(0), "Invalid data hash");

        cert.cid = newCid;
        cert.dataHash = newDataHash;

        emit CertificateUpdated(certificateId, msg.sender, newCid, newDataHash);
    }

    // ------------------------------------------------------------------------
    // Query Functions
    // ------------------------------------------------------------------------
    function getCertificate(uint256 certificateId)
        external
        view
        returns (
            uint256 id,
            address issuer,
            address recipient,
            string memory cid,
            bytes32 dataHash,
            uint256 issuedAt,
            bool revoked,
            uint256 revokedAt,
            string memory metadata
        )
    {
        Certificate storage cert = certificates[certificateId];
        require(cert.id != 0, "Certificate not found");

        return (
            cert.id,
            cert.issuer,
            cert.recipient,
            cert.cid,
            cert.dataHash,
            cert.issuedAt,
            cert.revoked,
            cert.revokedAt,
            cert.metadata
        );
    }

    function isRevoked(uint256 certificateId) external view returns (bool) {
        Certificate storage cert = certificates[certificateId];
        require(cert.id != 0, "Certificate not found");
        return cert.revoked;
    }

    function certificatesOfIssuer(address issuer)
        external
        view
        returns (uint256[] memory)
    {
        return issuedCertificates[issuer];
    }

    function certificatesOfRecipient(address recipient)
        external
        view
        returns (uint256[] memory)
    {
        return recipientCertificates[recipient];
    }

    function totalCertificates() external view returns (uint256) {
        return _nextCertificateId - 1;
    }

    function exists(uint256 certificateId) external view returns (bool) {
        return certificates[certificateId].id != 0;
    }
}
