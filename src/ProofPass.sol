// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title ProofPass
/// @notice An issuer-managed registry of privacy-preserving credentials.
/// @dev Store a credential digest on-chain; keep the underlying document off-chain.
contract ProofPass {
    error Unauthorized();
    error ZeroAddress();
    error EmptyCredentialHash();
    error CredentialAlreadyExists();
    error CredentialNotFound();
    error CredentialAlreadyRevoked();
    error IssuerAlreadyAuthorized();
    error IssuerNotAuthorized();

    struct Credential {
        address subject;
        address issuer;
        string metadataURI;
        uint64 issuedAt;
        uint64 revokedAt;
    }

    address public immutable owner;
    mapping(address issuer => bool) public authorizedIssuers;
    mapping(bytes32 credentialHash => Credential) private credentials;

    event IssuerAuthorized(address indexed issuer, address indexed authorizedBy);
    event IssuerRemoved(address indexed issuer, address indexed removedBy);
    event CredentialIssued(
        bytes32 indexed credentialHash,
        address indexed subject,
        address indexed issuer,
        string metadataURI
    );
    event CredentialRevoked(bytes32 indexed credentialHash, address indexed revokedBy, string reason);

    constructor(address initialIssuer) {
        if (initialIssuer == address(0)) revert ZeroAddress();
        owner = msg.sender;
        authorizedIssuers[initialIssuer] = true;
        emit IssuerAuthorized(initialIssuer, msg.sender);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier onlyIssuer() {
        if (!authorizedIssuers[msg.sender]) revert IssuerNotAuthorized();
        _;
    }

    function authorizeIssuer(address issuer) external onlyOwner {
        if (issuer == address(0)) revert ZeroAddress();
        if (authorizedIssuers[issuer]) revert IssuerAlreadyAuthorized();
        authorizedIssuers[issuer] = true;
        emit IssuerAuthorized(issuer, msg.sender);
    }

    function removeIssuer(address issuer) external onlyOwner {
        if (!authorizedIssuers[issuer]) revert IssuerNotAuthorized();
        authorizedIssuers[issuer] = false;
        emit IssuerRemoved(issuer, msg.sender);
    }

    function issueCredential(bytes32 credentialHash, address subject, string calldata metadataURI)
        external
        onlyIssuer
    {
        if (credentialHash == bytes32(0)) revert EmptyCredentialHash();
        if (subject == address(0)) revert ZeroAddress();
        if (credentials[credentialHash].issuedAt != 0) revert CredentialAlreadyExists();

        credentials[credentialHash] = Credential({
            subject: subject,
            issuer: msg.sender,
            metadataURI: metadataURI,
            issuedAt: uint64(block.timestamp),
            revokedAt: 0
        });
        emit CredentialIssued(credentialHash, subject, msg.sender, metadataURI);
    }

    /// @notice Revocation may be performed by the original issuer or registry owner.
    function revokeCredential(bytes32 credentialHash, string calldata reason) external {
        Credential storage credential = credentials[credentialHash];
        if (credential.issuedAt == 0) revert CredentialNotFound();
        if (credential.revokedAt != 0) revert CredentialAlreadyRevoked();
        if (msg.sender != owner && msg.sender != credential.issuer) revert Unauthorized();

        credential.revokedAt = uint64(block.timestamp);
        emit CredentialRevoked(credentialHash, msg.sender, reason);
    }

    function getCredential(bytes32 credentialHash) external view returns (Credential memory) {
        Credential memory credential = credentials[credentialHash];
        if (credential.issuedAt == 0) revert CredentialNotFound();
        return credential;
    }

    function isValid(bytes32 credentialHash) external view returns (bool) {
        Credential memory credential = credentials[credentialHash];
        return credential.issuedAt != 0 && credential.revokedAt == 0;
    }
}
