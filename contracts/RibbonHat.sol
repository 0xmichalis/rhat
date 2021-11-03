// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

/// Interface to the RHAT ERC20 contract
interface IRibbonHatToken {
    function balanceOf(address) external view returns (uint256);
    function increaseAllowance(address, uint256) external;
    function transferFrom(address from, address to, uint256 amount) external;
}

contract RibbonHat is ERC721, Pausable, AccessControl, ERC721Burnable {
    // stock fields
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // custom fields
    mapping(address => bool) public whitelist;
    IRibbonHatToken public rhatAddress;
    string private rhatTokenURI;
    uint256 private rhatTokenId;

    constructor(address rhatContractAddress, string memory rhatURI, address[] memory whitelistedAddresses) ERC721("RibbonHat", "TTRHAT") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        rhatAddress = IRibbonHatToken(rhatContractAddress);
        rhatTokenURI = rhatURI;
        for (uint i = 0; i < whitelistedAddresses.length; i++) {
            whitelist[whitelistedAddresses[i]] = true;
        }
    }

    /// @dev A modifier which checks that the caller is a RHAT holder.
    modifier onlyRhatHolder() {
        // Check whether sender has a RHAT ERC20
        // token or is part of the whitelist
        require(rhatAddress.balanceOf(msg.sender) > 0 || whitelist[msg.sender], "not a rhat holder");
        _;
    }

    /// @dev This is overriden to inject the RHAT IPFS URI in all RHAT NFTs
    function tokenURI(uint256) public view override returns (string memory) {
        // same hat for everyone
        return rhatTokenURI;
    }

    /// @dev mint ensures that only RHAT holders or whitelisted addresses
    /// can mint RHAT NFTs. For ERC20 holders, their token is transferred
    /// to this contract, then the mint is executed.
    /// Note that for RHAT ERC20 holders, first the current contract allowance
    /// needs to be increased in the RHAT ERC20 contract.
    function mint() public onlyRhatHolder() {
        if (!whitelist[msg.sender]) {
            rhatAddress.transferFrom(msg.sender, address(this), 1);
        } else {
            // Remove from whitelist to ensure only once semantics
            whitelist[msg.sender] = false;
        }
        // mint RHAT NFT for the RHAT holder
        _safeMint(msg.sender, rhatTokenId);
        rhatTokenId++;
    }

    // The following code is used as is and contains no changes
    // after being generated by the OpenZeppelin wizard.

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
