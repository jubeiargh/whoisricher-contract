// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract WhoIsRicherContract is Context, Ownable, ERC165 {
    string _name = "WhoIsRicher";
    string _symbol = "$$$";
    string _tokenURI = "https://cdn.whoisricher.io/metadata.json";

    address _richest;
    uint256 _wealth = 0 ether;
    address _communityWinner;
    uint8 _communitySharePercentage = 2;

    mapping(address => uint256) _pendingWithdrawals;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId,
        uint256 wealth
    );

    event CommunityWinnerChanged(address indexed to);

    event CommunitySharePercentageChanged(uint8 percentage);

    constructor() {
        _richest = owner();
        _communityWinner = _richest;

        emit Transfer(address(0), _richest, 1, 0 ether);
        emit CommunityWinnerChanged(_richest);
        emit CommunitySharePercentageChanged(_communitySharePercentage);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(tokenId == 1, "TokenURI query for nonexistent token");
        return _tokenURI;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Balance query for the zero address");
        if (owner == _richest) return 1;
        return 0;
    }

    function ownerOf(uint256 tokenId) public view returns (address owner) {
        require(tokenId == 1, "OwnerOf query for nonexistent token");
        return _richest;
    }

    function wealth() public view returns (uint256) {
        return _wealth;
    }

    function minimumBid() public view returns (uint256) {
        return _minimumBid();
    }

    function renounceOwnership() public virtual override onlyOwner {
        require(false, "Renouncing not allowed");
    }

    function becomeRichest() public payable {
        address sender = _msgSender();
        require(sender != _richest, "You are already the richest!");
        require(msg.value >= _minimumBid(), "Minimal amount not reached");

        address previousRichest = _richest;

        uint256 deltaWealth = msg.value - _wealth;
        uint256 richestShare = (deltaWealth * 75) / 100;
        uint256 communityShare = (deltaWealth * _communitySharePercentage) /
            100;
        uint256 developerShare = deltaWealth - richestShare - communityShare;

        _pendingWithdrawals[previousRichest] += _wealth + deltaWealth;
        _pendingWithdrawals[_communityWinner] += communityShare;
        _pendingWithdrawals[owner()] += developerShare;

        _richest = sender;
        _wealth = msg.value;

        emit Transfer(previousRichest, _richest, 1, _wealth);
    }

    function withdraw() public {
        address sender = _msgSender();
        uint256 amount = _pendingWithdrawals[sender];
        require(amount > 0, "No pending withdrawals");

        _pendingWithdrawals[sender] = 0;
        payable(sender).transfer(amount);
    }

    function setCommunitywinner(address newCommunityWinner)
        public
        onlyOwner
        returns (address)
    {
        require(
            _communityWinner != newCommunityWinner,
            "New community winner has to be someone new"
        );
        _communityWinner = newCommunityWinner;

        emit CommunityWinnerChanged(_communityWinner);
        return _communityWinner;
    }

    function setCommunitySharePercentage(uint8 communitySharePercentage)
        public
        onlyOwner
        returns (uint8)
    {
        require(
            communitySharePercentage <= 25,
            "Community share has to be equal or below 25 in order to not cut from title holders"
        );
        _communitySharePercentage = communitySharePercentage;

        emit CommunitySharePercentageChanged(_communitySharePercentage);

        return _communitySharePercentage;
    }

    function getCommunityWinner() public view returns (address) {
        return _communityWinner;
    }

    function getWithdrawableAmount() public view returns (uint256) {
        return _pendingWithdrawals[_msgSender()];
    }

    function _minimumBid() private view returns (uint256) {
        return (_wealth * 11) / 10;
    }
}
