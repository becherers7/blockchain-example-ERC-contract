pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract ExampleNFT is Pausable, Ownable, ERC721URIStorage {
    //Use counter for incrementing and decrementing created token Ids
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string private baseURI = "ipfs://";

    //map token owner wallet address to respective balance
    mapping(address => uint) public userBalance;
    
    //map token id to owner wallet address
    mapping(uint => address) private tokenOwner;
    
    //check for valid token holder
    mapping(address => mapping(string => bool)) private userNFTs;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {}

    /**
     * Returns the total supply of NFTs in the whole contract.
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    /**
    * @dev returns if a user has a NFT with a given name.
    */
    function hasNFT(address user, string memory name) public view returns (bool) {
        return userNFTs[user][name];
    }

    /**
    * @dev Award one token to the given address
    * @param _tokenURI The URI of the token to award
     */
    function mint(string memory _tokenURI) external whenNotPaused() returns (uint) {
        address payable userAddress = payable(msg.sender);
        require(bytes(_tokenURI).length > 0, "Empty _tokenURI is not allowed");
        require(!userNFTs[userAddress][_tokenURI], "User already has this NFT");
        userNFTs[userAddress][_tokenURI] = true;
        uint tokenId = _tokenIds.current();
        _mint(userAddress, tokenId);
        _setTokenURI(tokenId, string(abi.encodePacked(baseURI, _tokenURI)));
        tokenOwner[tokenId] = userAddress;
        userBalance[userAddress]++;
        _tokenIds.increment();
        return tokenId;
    }

    /**
    * @dev transfer a token from one address to another, only if the sender has the token
    * @param _to The address that will receive the token.
    * @param _tokenId The token id of the token to be minted.
    */
    function transferToken(address _to, uint _tokenId) external whenNotPaused() {
        transferFrom(msg.sender, _to, _tokenId);
    }

    /**
   function that allows the owner to transfer any token to any other address
   */
    function ownerTransferToken(address _to, uint _tokenId) external whenNotPaused() onlyOwner() {
        transferFrom(tokenOwner[_tokenId], _to, _tokenId);
    }

    /**
    function to burn an nft with tokenId and userAddress
    */
    function burn(uint tokenId, address userAddress) external onlyOwner() whenNotPaused() {
        require(userAddress != address(0), "Address 0 not allowed"); // 0x0 is not allowed
        require(tokenId < _tokenIds.current(), "TokenId must be less than totalSupply"); // tokenId must be less than totalSupply
        require(tokenOwner[tokenId] == userAddress, "You are not the owner of this token"); // userAddress must be the owner of this token
        _burn(tokenId);
        _tokenIds.decrement();
        userBalance[userAddress]--;
        tokenOwner[tokenId] = address(0);
    }

    /**
    function to burn all tokens at once for all the users
    */
    function burnAll() external onlyOwner() whenNotPaused() {
        require(_tokenIds.current() > 0, "No NFTs to burn"); // no nfts to burn
        uint nftsToBurn = _tokenIds.current();
        for (uint i = 0; i < nftsToBurn; i++) {
            _burn(i);
            userBalance[tokenOwner[i]] = userBalance[tokenOwner[i]] - 1;
            tokenOwner[i] = address(0);
        }
    }

    /**
    function to pause the contract to avoid minting and burning of tokens
    */
    function pauseContract() external onlyOwner() {
        if(paused()) {
            _unpause();
        } else {
            _pause();
        }
    }

    /**
    @dev function for contract to self destruct
    */
    function selfDestruct() external onlyOwner() {
        selfdestruct(payable(owner()));
    }

    /**
    The unnamed function commonly referred to as “fallback function” was split up into a new fallback function that is defined using the fallback keyword and a receive ether function defined using the receive keyword. IMPLEMENT FUTURE
    */
    // fallback() external payable {
    //     (bool sent,) = msg.sender.call{value: msg.value}("");
    //     require(sent, "Failed to send Ether");
    // }
}

//IMPLEMENT FUTURE
// contract IERC721Receiver {
//     /**
//      * @notice Handle the receipt of an NFT
//      * @dev The ERC721 smart contract calls this function on the recipient
//      * after a `safeTransfer`. This function MUST return the function selector,
//      * otherwise the caller will revert the transaction. The selector to be
//      * returned can be obtained as `this.onERC721Received.selector`. This
//      * function MAY throw to revert and reject the transfer.
//      * Note: the ERC721 contract address is always the message sender.
//      * @param operator The address which called `safeTransferFrom` function
//      * @param from The address which previously owned the token
//      * @param tokenId The NFT identifier which is being transferred
//      * @param data Additional data with no specified format
//      * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
//      */
//     function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
//     public returns (bytes4);
// }