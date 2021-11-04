// SPDX-License-Identifier: ISC
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// Interface to the RHAT ERC20 contract
interface IRibbonHatToken {
    function balanceOf(address) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external;
}

contract RibbonHat is ERC1155, Ownable {
    mapping(address => bool) public whitelist;
    IRibbonHatToken public rhatErc20Address;

    constructor(
        address erc20Address,
        address multisigAddress,
        string memory rhatURI,
        address[] memory whitelistedAddresses
    ) ERC1155(rhatURI) {
        rhatErc20Address = IRibbonHatToken(erc20Address);
        for (uint i = 0; i < whitelistedAddresses.length; i++) {
            whitelist[whitelistedAddresses[i]] = true;
        }
    }

    /// @dev A modifier which checks that the caller is eligible to mint RHAT.
    modifier onlyRhatHolder() {
        // Check whether sender has a RHAT ERC20
        // token or is part of the whitelist
        require(rhatErc20Address.balanceOf(msg.sender) > 0 || whitelist[msg.sender], "not eligible for rhat");
        _;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    /// @dev mint ensures that only RHAT ERC20 holders or whitelisted addresses
    /// can mint RHAT NFTs. For ERC20 holders, their token is transferred
    /// to this contract, then the mint is executed.
    /// Note that for RHAT ERC20 holders, first the current contract allowance
    /// needs to be increased in the RHAT ERC20 contract.
    function mint() external onlyRhatHolder {
        if (!whitelist[msg.sender]) {
            rhatErc20Address.transferFrom(msg.sender, address(this), 1);
        } else {
            // Remove from whitelist to ensure only once semantics
            whitelist[msg.sender] = false;
        }
        // mint RHAT NFT for the RHAT holder
        _mint(msg.sender, 0, 1, "");
    }

    function addToWhitelist(address whitelisted) external onlyOwner {
        whitelist[whitelisted] = true;
    }
}
