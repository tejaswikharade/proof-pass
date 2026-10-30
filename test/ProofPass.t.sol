// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ProofPass} from "../src/ProofPass.sol";

interface Vm {
    function prank(address) external;
    function expectRevert(bytes4) external;
}

contract ProofPassTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    ProofPass private registry;
    address private constant ISSUER = address(0xA11CE);
    address private constant OTHER_ISSUER = address(0xB0B1);
    address private constant SUBJECT = address(0xB0B);
    bytes32 private constant DIGEST = keccak256("proofpass:credential:001");

    function setUp() public {
        registry = new ProofPass(ISSUER);
    }

    function testInitialIssuerCanIssueAndLookup() public {
        vm.prank(ISSUER);
        registry.issueCredential(DIGEST, SUBJECT, "ipfs://bafy-proof-pass-001");

        ProofPass.Credential memory credential = registry.getCredential(DIGEST);
        require(credential.subject == SUBJECT, "wrong subject");
        require(credential.issuer == ISSUER, "wrong issuer");
        require(registry.isValid(DIGEST), "credential should be valid");
    }

    function testOwnerCanAuthorizeAnotherIssuer() public {
        registry.authorizeIssuer(OTHER_ISSUER);
        vm.prank(OTHER_ISSUER);
        registry.issueCredential(DIGEST, SUBJECT, "ar://credential");
        require(registry.isValid(DIGEST), "new issuer could not issue");
    }

    function testUnauthorizedAccountCannotIssue() public {
        vm.expectRevert(ProofPass.IssuerNotAuthorized.selector);
        vm.prank(SUBJECT);
        registry.issueCredential(DIGEST, SUBJECT, "ipfs://private");
    }

    function testIssuerCanRevokeOwnCredential() public {
        vm.prank(ISSUER);
        registry.issueCredential(DIGEST, SUBJECT, "ipfs://credential");
        vm.prank(ISSUER);
        registry.revokeCredential(DIGEST, "identity check failed");
        require(!registry.isValid(DIGEST), "credential should be revoked");
    }

    function testDifferentIssuerCannotRevokeCredential() public {
        vm.prank(ISSUER);
        registry.issueCredential(DIGEST, SUBJECT, "ipfs://credential");
        registry.authorizeIssuer(OTHER_ISSUER);
        vm.expectRevert(ProofPass.Unauthorized.selector);
        vm.prank(OTHER_ISSUER);
        registry.revokeCredential(DIGEST, "not allowed");
    }

    function testRemovedIssuerCannotIssue() public {
        registry.removeIssuer(ISSUER);
        vm.expectRevert(ProofPass.IssuerNotAuthorized.selector);
        vm.prank(ISSUER);
        registry.issueCredential(DIGEST, SUBJECT, "ipfs://credential");
    }
}
