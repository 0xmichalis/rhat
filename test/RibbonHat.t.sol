// SPDX-License-Identifier: ISC
pragma solidity ^0.8.4;

import 'forge-std/Test.sol';

import { RibbonHat } from '../src/RibbonHat.sol';
import { RibbonHatToken } from './RibbonHatToken.sol';

contract RibbonHatTest is Test {
    // users
    address constant julian = address(0x69);
    address constant aeto = address(0x70);
    address constant ngmi = address(0x71);
    address constant gov = address(0xf00); // useless
    address constant uh = address(0xdead);
    string constant uri = 'ipfs://bafkreifis4mzcvhjahpjoyqep3nz5yq6dquic3lkgcubg6za6lsfjb5t4m';

    // ERC20
    RibbonHatToken rhatErc20;

    // NFT
    RibbonHat rhat;

    function setUp() public {
        rhatErc20 = new RibbonHatToken('Ribbon Hat', 'RHAT', 64, julian);

        address[] memory whitelistedUsers = new address[](1);
        whitelistedUsers[0] = ngmi;

        vm.deal(julian, 1 ether);
        vm.deal(aeto, 1 ether);
        vm.deal(ngmi, 1 ether);
        vm.deal(gov, 1 ether);
        vm.deal(uh, 1 ether);

        vm.prank(julian);
        rhatErc20.transfer(aeto, 1);

        rhat = new RibbonHat(address(rhatErc20), gov, uri, whitelistedUsers);
    }

    function testWhitelisted() public {
        vm.prank(ngmi);
        rhat.mint();        
    }

    function testCannotMintMoreThanOnce() public {
        vm.prank(ngmi);
        rhat.mint();
        // cannot mint a second time
        vm.prank(ngmi);
        vm.expectRevert('not eligible for rhat');
        rhat.mint();
    }

    function testMint() public {
        vm.prank(aeto);
        rhatErc20.approve(address(rhat), 1);
        vm.prank(aeto);
        rhat.mint();
    }

    function testCannotMint() public {
        vm.prank(uh);
        vm.expectRevert('not eligible for rhat');
        rhat.mint();
    }

    function testCannotMintGov() public {
        vm.prank(gov);
        vm.expectRevert('not eligible for rhat');
        rhat.mint();
    }

    function testCannotMintOwner() public {
        vm.expectRevert('not eligible for rhat');
        rhat.mint();
    }
}
