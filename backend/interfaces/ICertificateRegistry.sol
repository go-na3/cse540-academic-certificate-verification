
// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

/**
 * @title ICertificateRegistry
 * @notice Public interface for the Academic Certificate Verification System.
 * @dev This interface declares the core functions and events of the CertificateRegistry contract.
 * It allows other smart contracts or front-end clients to interact with the registry
 */
interface ICertificateRegistry {
    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------

    /// @notice Emitted when a certificate is issued by an authorized issuer.
    event CertificateIssued(
        uint256 indexed certificateId,
        address indexed issuer,
        address indexed recipient,
        string cid,
        bytes32 dataHash
    );

    /// @notice Emitted when a certificate is revoked by an issuer or admin.
    event CertificateRevoked(
        uint256 indexed certificateId,
        address indexed issuer,
        uint256 revokedAt
    );

    /// @notice Emitted when a certificate's IPFS CID or dataHash is updated.
    event CertificateUpdated(
        uint256 indexed certificateId,
        address indexed issuer,
        string newCid,
        bytes32 newDataHash
    );

    /// @notice Emitted when a new issuer is granted the issuer role.
    event IssuerAdded(address indexed account);

    /// @notice Emitted when an issuer is revoked of the issuer role.
    event IssuerRemoved(address indexed account);

    // ------------------------------------------------------------------------
    // Role-Based Access Control Functions
    // ------------------------------------------------------------------------

    /**
     * @notice Grants issuing authority to a new address.
     * @dev Only a contract admin can call this.
     * @param _issuerAddress The address to grant issuer privileges.
     */
    function addIssuer(address _issuerAddress) external;

    /**
     * @notice Revokes issuing authority from an address.
     * @dev Only a contract admin can call this.
     * @param _issuerAddress The address to revoke issuer privileges.
     */
    function removeIssuer(address _issuerAddress) external;

    /**
     * @notice Checks if a given address has issuer privileges.
     * @dev Public view function for checks.
     * @param _issuerAddress The address to check.
     * @return A boolean, true if the address is an authorized issuer.
     */
    function isIssuer(address _issuerAddress) external view returns (bool);

    /**
     * @notice Checks if a given address has admin privileges.
     * @dev Public view function for checks.
     * @param _adminAddress The address to check.
     * @return A boolean, true if the address is an authorized admin.
     */
    function isAdmin(address _adminAddress) external view returns (bool);

    // ------------------------------------------------------------------------
    // Core Certificate Lifecycle Functions
    // ------------------------------------------------------------------------

    /**
     * @notice Issues a new certificate record to the blockchain.
     * @dev Can only be called by an address with the Issuer Role.
     * @param recipient  The blockchain address of the student or certificate owner.
     * @param cid        The IPFS Content Identifier (CID) of the off-chain certificate file.
     * @param dataHash   The cryptographic hash (e.g., SHA-256) of the certificate file.
     * @param metadata   Optional metadata string describing the credential.
     * @return certificateId The unique ID assigned to the new certificate.
     */
    function issueCertificate(
        address recipient,
        string calldata cid,
        bytes32 dataHash,
        string calldata metadata
    ) external returns (uint256 certificateId);

    /**
     * @notice Revokes a previously issued certificate.
     * @dev Can only be called by an authorized issuer or an admin.
     * @param certificateId The ID of the certificate to revoke.
     */
    function revokeCertificate(uint256 certificateId) external;

    /**
     * @notice Updates a certificate’s IPFS CID or dataHash (for version control).
     * @dev Can only be called by the original issuer or an admin.
     * @param certificateId The ID of the certificate to update.
     * @param newCid The new IPFS CID (must not be empty).
     * @param newDataHash The new data hash (must not be zero).
     */
    function updateCertificate(
        uint256 certificateId,
        string calldata newCid,
        bytes32 newDataHash
    ) external;

    // ------------------------------------------------------------------------
    // Query Functions
    // ------------------------------------------------------------------------

    /**
     * @notice Returns full metadata for a given certificate ID.
     * @param certificateId The ID of the certificate to query.
     */
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
        );

    /**
     * @notice Checks whether a certificate has been revoked.
     * @param certificateId The ID of the certificate.
     */
    function isRevoked(uint256 certificateId) external view returns (bool);

    /**
     * @notice Lists all certificate IDs issued by a specific issuer.
     * @dev Supports the "University UI"[cite: 39].
     * @param issuer The address of the issuer (university).
     */
    function certificatesOfIssuer(address issuer)
        external
        view
        returns (uint256[] memory);

    /**
     * @notice Lists all certificate IDs for a specific recipient (student).
     * @dev Supports the "Student Portal" to "Access issued certificates" [cite: 44-46].
     * @param recipient The address of the recipient (student).
     */
    function certificatesOfRecipient(address recipient)
        external
        view
        returns (uint256[] memory);

    /**
     * @notice Returns total number of certificates issued.
     */
    function totalCertificates() external view returns (uint256);

    /**
     * @notice Checks if a certificate exists.
     * @param certificateId The ID to check.
     */
    function exists(uint256 certificateId) external view returns (bool);
}
