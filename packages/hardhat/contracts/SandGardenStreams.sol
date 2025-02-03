pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

contract SandGardenStreams is Ownable {

    struct BuilderStreamInfo {
        uint256 cap;
        uint256 last;
    }
    mapping(address => BuilderStreamInfo) public streamedBuilders;
    uint256 public frequency = 2592000; // 30 days

    event Withdraw(address indexed to, uint256 amount, string reason);
    event AddBuilder(address indexed to, uint256 amount);
    event UpdateBuilder(address indexed to, uint256 amount);

    constructor() { 
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "End of Batch 12; hanging up the Batch Dad hat for now. Thanks so much for the opportunity to support and onboard these buidlers! It's been an honor.");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Batch 12 Week 3: PRs and cheerleading");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Batch 12 ongoing, predominantly PR reviews");
        emit Withdraw(0x699bFaC97c962db31238B429cEaF6734C492d61C, 450000000000000000, "Finishing up Batch 11, Setup of Batch 12, Management of Batch 12, PRs");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Launch batch 12: first wave of PRs, cheerleading, and trying to activate members that haven't jumped in yet");
        emit Withdraw(0x699bFaC97c962db31238B429cEaF6734C492d61C, 450000000000000000, "Ran Batch 11");
        emit Withdraw(0x699bFaC97c962db31238B429cEaF6734C492d61C, 500000000000000000, "Batch 10, set up, all reviews, management, Batch 11 set up");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Wrap up Batch 10, hand off for 11");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Batch 10, ENS, feedback");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Batch 10 week 2, including a light slap on the hand for a particularly impatient fellow");
        emit Withdraw(0x699bFaC97c962db31238B429cEaF6734C492d61C, 500000000000000000, "Batch 9 management and support with reviewing PRs");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Batch 10 prep and launch");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Batch 9 wrap up, 1-on-1 guidance");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Batch 9: PR reviews, ENS, blocked a turd trying to double-dip in Batch 9 and 10");
        emit Withdraw(0x699bFaC97c962db31238B429cEaF6734C492d61C, 500000000000000000, "Support of Batch 8,9, code reviews, setup, tracking participation");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Big week of Batch 9 engagement; quite a few eager beavers diving in and needing cat-herding.");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Batch 9 set up");
        emit Withdraw(0x2606Cb984B962AD4aA1ef00f9AF9b654b435ad44, 300000000000000000, "Batch 8 wrap-up, including a bunch of sweet cross-batch feedback on the last PR. The most active batch I've seen so far!");
        emit Withdraw(0x699bFaC97c962db31238B429cEaF6734C492d61C, 500000000000000000, "Support of Batch 7, 8, reviewing PRs, reviewing grants application and giving feedback");

        _transferOwnership(0x11E91FB4793047a68dFff29158387229eA313ffE);
    }

    struct BuilderData {
        address builderAddress;
        uint256 cap;
        uint256 unlockedAmount;
    }

    function allBuildersData(address[] memory _builders) public view returns (BuilderData[] memory) {
        BuilderData[] memory result = new BuilderData[](_builders.length);
        for (uint256 i = 0; i < _builders.length; i++) {
            address builderAddress = _builders[i];
            BuilderStreamInfo storage builderStream = streamedBuilders[builderAddress];
            result[i] = BuilderData(builderAddress, builderStream.cap, unlockedBuilderAmount(builderAddress));
        }
        return result;
    }

    function unlockedBuilderAmount(address _builder) public view returns (uint256) {
        BuilderStreamInfo memory builderStream = streamedBuilders[_builder];
        if (builderStream.cap == 0) {
            return 0;
        }

        if (block.timestamp - builderStream.last > frequency) {
            return builderStream.cap;
        }

        return (builderStream.cap * (block.timestamp - builderStream.last)) / frequency;
    }

    function addBuilderStream(address payable _builder, uint256 _cap) public onlyOwner {
        streamedBuilders[_builder] = BuilderStreamInfo(_cap, block.timestamp - frequency);
        emit AddBuilder(_builder, _cap);
    }

    function addBatch(address[] memory _builders, uint256[] memory _caps) public onlyOwner {
        require(_builders.length == _caps.length, "Lengths are not equal");
        for (uint256 i = 0; i < _builders.length; i++) {
            addBuilderStream(payable(_builders[i]), _caps[i]);
        }
    }

    function updateBuilderStreamCap(address payable _builder, uint256 _cap) public onlyOwner {
        BuilderStreamInfo memory builderStream = streamedBuilders[_builder];
        require(builderStream.cap > 0, "No active stream for builder");
        streamedBuilders[_builder].cap = _cap;
        emit UpdateBuilder(_builder, _cap);
    }

    function streamWithdraw(uint256 _amount, string memory _reason) public {
        require(address(this).balance >= _amount, "Not enough funds in the contract");
        BuilderStreamInfo storage builderStream = streamedBuilders[msg.sender];
        require(builderStream.cap > 0, "No active stream for builder");

        uint256 totalAmountCanWithdraw = unlockedBuilderAmount(msg.sender);
        require(totalAmountCanWithdraw >= _amount,"Not enough in the stream");

        uint256 cappedLast = block.timestamp - frequency;
        if (builderStream.last < cappedLast){
            builderStream.last = cappedLast;
        }

        builderStream.last = builderStream.last + ((block.timestamp - builderStream.last) * _amount / totalAmountCanWithdraw);

        (bool sent,) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        emit Withdraw(msg.sender, _amount, _reason);
    }

    // to support receiving ETH by default
    receive() external payable {}
    fallback() external payable {}
}
