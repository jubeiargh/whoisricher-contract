// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/utils/introspection/ERC165.sol';

contract WhoIsRicherContract is Context, Ownable, ERC165 {
    string _name = 'WhoIsRicher';
    string _symbol = '$$$';
    string _tokenURI = 'https://cdn.whoisricher.io/metadata.json';

    address _richest;
    uint256 _wealth = 0 ether;

    mapping(address => uint256) _pendingWithdrawals;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        uint256 wealth
    );

    constructor() {
        _richest = owner();

        emit Transfer(address(0), owner(), 1, 0 ether);
    }


    function name() public view  returns (string memory) {
        return _name;
    }

    function symbol() public view  returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        require(tokenId == 1, 'TokenURI query for nonexistent token');
        return _tokenURI;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), 'Balance query for the zero address');
        if (owner == _richest) return 1;
        return 0;
    }


    function ownerOf(uint256 tokenId)
        public
        view
        returns (address owner)
    {
        require(tokenId == 1, 'OwnerOf query for nonexistent token');
        return _richest;
    }

    function wealth() public view returns (uint256) {
        return _wealth;
    }

    function minimumBid() public view returns (uint256) {
        return _minimumBid();
    }

    function becomeRichest() public payable {
        require(_msgSender() != _richest, 'You are already the richest!');
        require(msg.value > _minimumBid(), 'Minimal amount not reached');

        uint256 deltaWealth = ((msg.value - _wealth) * 5) / 10;
        _pendingWithdrawals[owner()] += deltaWealth;
        _pendingWithdrawals[_richest] += _wealth + deltaWealth;

        address previousRichest = _richest;

        emit Transfer(previousRichest, _msgSender(), 1, msg.value);

        _richest = _msgSender();
        _wealth = msg.value;
    }

    function withdraw() public {
        uint256 amount = _pendingWithdrawals[_msgSender()];
        require(amount > 0, 'No pending withdrawals');

        _pendingWithdrawals[_msgSender()] = 0;
        payable(_msgSender()).transfer(amount);
    }

    function getWithdrawableAmount() public returns (uint256){
        return _pendingWithdrawals[_msgSender()];
    }

    function _minimumBid() private view returns (uint256) {
        return (_wealth * 11) / 10;
    }
}
