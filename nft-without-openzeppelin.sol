// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract HafsasNFT {
    
     uint256 public constant MAX_SUPPLY = 500;        // Maximum total NFTs
    uint256 public constant MINT_PRICE = 0.03 ether; // Mint price per NFT
    uint256 public constant PER_WALLET_LIMIT = 3;    // Max NFTs per wallet
    uint256 public constant RESERVED_TOKENS = 50;    // Owner-only reserved mints
    uint256 public constant START_TOKEN_ID = 1;      // Token IDs start from 1

    string public name = "Hafsa's1stNFT";   // Collection Name
    string public symbol = "HAFSO";         // Collection Symbol

    address public contractOwner;
    uint256 private _totalSupply; // Tracks minted supply including reserved
    uint256 private _reservedMinted; // Tracks reserved supply usage

    // NFT ownership mapping
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    // Approvals
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Per wallet mint tracking
    mapping(address => uint256) private _mintedCount;

    // Base URI for metadata (customize for IPFS or server)
    string private _baseTokenURI = "ipfs://yourBaseCID/";

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Not contract owner");
        _;
    }

    constructor() {
        contractOwner = msg.sender; // set deployer as owner
    }

     function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Zero address not allowed");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token does not exist");
        return owner;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return string(abi.encodePacked(_baseTokenURI, uint2str(tokenId), ".json"));
    }

    function mint(uint256 tokenId) public payable {
        require(tokenId >= START_TOKEN_ID && tokenId < START_TOKEN_ID + MAX_SUPPLY, "Invalid tokenId");
        require(_owners[tokenId] == address(0), "Token already minted");
        require(msg.value >= MINT_PRICE, "Not enough ETH sent");
        require(_mintedCount[msg.sender] < PER_WALLET_LIMIT, "Wallet mint limit reached");
        require(_totalSupply - _reservedMinted < MAX_SUPPLY - RESERVED_TOKENS, "Public supply exhausted");

        _mint(msg.sender, tokenId);
        _mintedCount[msg.sender]++;
    }

    // Owner reserved mint
    function ownerMint(uint256 tokenId) public onlyOwner {
        require(_reservedMinted < RESERVED_TOKENS, "All reserved tokens minted");
        require(_owners[tokenId] == address(0), "Token already minted");

        _mint(msg.sender, tokenId);
        _reservedMinted++;
    }

    // Core mint logic
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "Cannot mint to zero address");
        _owners[tokenId] = to;
        _balances[to] += 1;
        _totalSupply++;
        emit Transfer(address(0), to, tokenId);
    }

    // ============================================================
    // TRANSFERS
    // ============================================================
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not owner nor approved");
        require(ownerOf(tokenId) == from, "Incorrect from address");
        require(to != address(0), "Cannot transfer to zero address");

        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // ============================================================
    // APPROVALS
    // ============================================================
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "Approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _approve(to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Cannot approve self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    // ============================================================
    // WITHDRAWAL
    // ============================================================
    function withdraw() public onlyOwner {
        payable(contractOwner).transfer(address(this).balance);
    }

    // ============================================================
    // HELPER (convert uint to string)
    // ============================================================
    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (_i != 0) {
            bstr[k--] = bytes1(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}
