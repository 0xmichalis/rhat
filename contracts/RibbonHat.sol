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
    // Contract name
    string public name;
    // Contract symbol
    string public symbol;
    // Allow the multisig to onboard new members
    // plus existing members who lost their ERC20s
    mapping(address => bool) public whitelist;
    // RHAT ERC20 address
    IRibbonHatToken public erc20Address;
    // RHAT multisig address
    address public multisigAddress;

    constructor(
        address _erc20Address,
        address _multisigAddress,
        string memory uri,
        address[] memory whitelistedAddresses
    ) ERC1155(uri) {
        name = "RibbonHat";
        symbol = "RHAT";
        erc20Address = IRibbonHatToken(_erc20Address);
        multisigAddress = _multisigAddress;
        for (uint i = 0; i < whitelistedAddresses.length; i++) {
            whitelist[whitelistedAddresses[i]] = true;
        }
    }

    /// @dev A modifier which checks that the caller is eligible to mint RHAT.
    modifier onlyRhatHolder() {
        // Check whether sender has a RHAT ERC20 token,
        // is part of the whitelist, or is the contract owner
        require(erc20Address.balanceOf(msg.sender) > 0 || whitelist[msg.sender] || multisigAddress == msg.sender, "not eligible for rhat");
        _;
    }

    modifier onlyMultisig() {
        require(multisigAddress == msg.sender, "not the rhat multisig");
        _;
    }

    /// @dev Transfers ownership of the contract to a new account (`newOwner`).
    /// * Can only be called by the current owner.
    function transferOwnership(address newOwner) public override onlyMultisig {
        require(newOwner != address(0), "new owner is the zero address");
        transferOwnership(newOwner);
    }

    function setURI(string memory newuri) public onlyMultisig {
        _setURI(newuri);
    }

    /// @dev mint ensures that only RHAT ERC20 holders or whitelisted addresses
    /// can mint RHAT NFTs. For ERC20 holders, their token is transferred
    /// to this contract, then the mint is executed.
    /// Note that for RHAT ERC20 holders, first the current contract allowance
    /// needs to be increased in the RHAT ERC20 contract.
    function mint() external onlyRhatHolder {
        if (erc20Address.balanceOf(msg.sender) > 0) {
            erc20Address.transferFrom(msg.sender, address(this), 1);
        } else if (whitelist[msg.sender]) {
            // Remove from whitelist to ensure only once semantics
            whitelist[msg.sender] = false;
        }
        // mint RHAT NFT for the RHAT holder
        _mint(msg.sender, 0, 1, "");
    }
}
