// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
  Minimal BAYC-style NFT example (inspired pattern, NOT the real BAYC code).
  Features:
  - ERC721 with Counters
  - maxSupply
  - mint (public)
  - provenanceHash
  - reveal / baseURI / placeholderURI
  - EIP-2981 royalties
  - owner withdraw
*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract ApeLike is ERC721, ERC2981, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint256 public immutable maxSupply;
    uint256 public mintPrice;
    bool public saleActive;
    bool public revealed;
    string private baseTokenURI;
    string private placeholderURI;
    string public provenanceHash; // set once by owner

    event Minted(address indexed minter, uint256 indexed tokenId);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_,
        string memory placeholderURI_,
        uint96 royaltyNumerator // fee numerator out of 10000 (e.g., 500 = 5%)
    ) ERC721(name_, symbol_) {
        maxSupply = maxSupply_;
        placeholderURI = placeholderURI_;
        mintPrice = 0.08 ether; // example price
        saleActive = false;
        revealed = false;
        _setDefaultRoyalty(msg.sender, royaltyNumerator);
    }

    // ------- MINTING -------
    function mint(uint256 quantity) external payable {
        require(saleActive, "Sale is not active");
        require(quantity > 0, "Quantity 0");
        require(totalSupply() + quantity <= maxSupply, "Max supply reached");
        require(msg.value >= mintPrice * quantity, "Ether sent insufficient");

        for (uint256 i = 0; i < quantity; i++) {
            _mintOne(msg.sender);
        }
    }

    function _mintOne(address to) internal {
        _tokenIdCounter.increment();
        uint256 newId = _tokenIdCounter.current();
        _safeMint(to, newId);
        emit Minted(to, newId);
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    // ------- ADMIN only -------
    function setMintPrice(uint256 newPrice) external onlyOwner {
        mintPrice = newPrice;
    }

    function flipSaleState() external onlyOwner {
        saleActive = !saleActive;
    }

    function setProvenanceHash(string calldata hash_) external onlyOwner {
        // should be set once ideally
        provenanceHash = hash_;
    }

    function setPlaceholderURI(string calldata uri_) external onlyOwner {
        placeholderURI = uri_;
    }

    function reveal(string calldata newBaseURI) external onlyOwner {
        baseTokenURI = newBaseURI;
        revealed = true;
    }

    // ------- metadata -------
    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Nonexistent token");
        if (!revealed) {
            return placeholderURI;
        }
        return string(abi.encodePacked(_baseURI(), _toString(tokenId), ".json"));
    }

    // helper toString (simple)
    function _toString(uint256 value) internal pure returns (string memory) {
        // adapted from OpenZeppelin Strings but implemented inline to avoid import
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    // ------- withdraw funds -------
    function withdraw() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "No funds");
        (bool ok, ) = payable(owner()).call{value: bal}("");
        require(ok, "Withdraw failed");
    }

    // ------- royalties (EIP-2981) -------
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    // ------- overrides -------
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // fallback to receive ETH
    receive() external payable {}
}