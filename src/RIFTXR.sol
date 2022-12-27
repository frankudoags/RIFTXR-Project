//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

    /**
    *@title - RIFTXR MetaPasses
    *@author - Frank Udoags twitter: @FrankUdoags1
    */

contract RIFTXR is ERC721A, Ownable{
    using MerkleProof for bytes32[];

 /* ––– ERRORS ––– */

    /**
     *@notice Not whitelisted
     */
    error RIFT__notInPassesList();
    /**
     *@notice Transfer failed
     */
    error RIFT__transferFailed();
    /**
     *@notice Only Externally owned accounts
     */
    error RIFT__onlyEOA();
    /**
     *@notice Minted out
     */
    error RIFT__notEnoughPassesRemaining();
    /**
     *@notice incorrect Payment
     */
    error RIFT__incorrectPayment();
    /**
     *@notice Address has minted max per wallet
     */
    error RIFT__maxMintablePassesExceeded();
    /**
     *@notice Number of Tokens is higher than the maximum allowable mints
     */
    error RIFT__numOfTokensTooHigh();
    /**
     *@notice   Minting not yet enabled
     */
    error RIFT__mintNotEnabled();

    //==========================END OF ERRORS==========================






  /* ============PUBLIC VARIABLES=============== */

    /**
    *@notice - Mint Price in ether
     */
    uint256 constant MINT_PRICE = 0.05 ether;
    /**
    *@notice -Variable to indicate public minting state(Enabled/Disabled)
     */
    bool public mintEnabled;
    /** 
     *@notice – Maximum token supply
     */
    uint256 immutable MAX_SUPPLY = 500;
    /*
     * @notice – MerkleProof root for verifying allowlist addresses
     * @notice – Set by `setMerkleRoot()`
     */
    bytes32 public merkleRoot;
    /*
     * @notice – Token Base URI 
     * @notice – Passed into constructor and also can be set by `setBaseURI()`
     */
    string public baseURI;
    /**
     * @notice – variable that controls the collection reveal
     * @notice – set by `reveal()`
     */
    bool public revealed;
    /**
     * @notice – variable for token URI when collection is not revealed
     * @notice – set by `setNotRevealedURI()`
     */
    string public notRevealedURI;
    /**=================END OF PUBLIC VARIABLES=================== */



    /**
    *@dev Constructor
     */
     constructor() ERC721A("RIFTXR", "RFT") {
    }

      /* ============OnlyOwner Functions, hehe.=============== */

    /**
    *@dev function to set MintEnabled to true or false
    *@param _mintEnabled : new state of mintEnabled
     */
    function setMintEnabled(bool _mintEnabled) external onlyOwner {
        mintEnabled = _mintEnabled;
    }
    /**
    *@dev function to set MerkleRoot
     *@param _merkleRoot: New root to set
     */
     function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
         merkleRoot = _merkleRoot;
     }
    /**
    *@dev Reveal Collection's metadata
    */
     function reveal() external onlyOwner {
        revealed = true;
    }
     /**
     * @notice – Sets the base URI to the given string
     * @param  _baseuri - New base URI to set
     */
     function setBaseURI(string memory _baseuri) external onlyOwner {
        baseURI = _baseuri;
    }
    /**
     * @notice – Sets the not revealed URI to the given string
     * @param  _notRevealedURI - New notRevealedURI to set
     */
      function setNotRevealedURI(string memory _notRevealedURI) external onlyOwner {
        notRevealedURI = _notRevealedURI;
    }

    /* ============End of OnlyOwner Functions.=============== */






    //==============================URI FUNCTIONS==============================

     /**
     * @notice – returns the base URI 
     */
      function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
    /** 
     * @notice – Returns the URI of the tokenID passed into it.
     * @param _tokenID: tokenID to fetch it's URI
     */
    function tokenURI(uint256 _tokenID) public view override returns (string memory) {
        require(_exists(_tokenID),"Nonexistent token");
        if(revealed == false) return notRevealedURI;
              string memory _baseURIChecker = _baseURI();
        return bytes(_baseURIChecker).length > 0 ? string( abi.encodePacked(baseURI, "/", _toString(_tokenID), ".json") ) : "";
    }

   
     //==============================END OF URI FUNCTIONS==============================


    

       /*================MODIFIERS================== */
       modifier isCorrectPayment(uint256 price, uint256 numberOfTokens) {
        if((price * numberOfTokens) != msg.value) 
        revert RIFT__incorrectPayment();
        _;
    }
       modifier RIFTList(bytes32[] calldata _merkleProof) {
        if(!MerkleProof.verify(_merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender) )))
          revert RIFT__notInPassesList();
        _;
    }   
    modifier enoughPassesRemaining(uint256 numberOfTokens) {
        if(_totalMinted() + numberOfTokens > MAX_SUPPLY ) 
        revert RIFT__notEnoughPassesRemaining();
        _;
    }
     modifier maxPassesPerWallet(uint256 numberOfTokens) {
         if(_numberMinted(msg.sender) >= 3)
            revert RIFT__maxMintablePassesExceeded();
            _;
     }
     modifier checkNumOfTokens(uint256 numberOfTokens) {
         if(numberOfTokens > 3)  
         revert RIFT__numOfTokensTooHigh();
         _;
     }
     modifier isMintEnabled() {
         if(mintEnabled == false) revert RIFT__mintNotEnabled();
         _;
     }

    /**===================END OF MODIFIERS==================== */







    /*================= MINT FUNCTION================== */ 
    /** 
     * @notice – WL Mint Function
     * @param numberOfTokens - Number of tokens to mint
     * @param _merkleProof - merkleproof of the address that is allowed to mint
     */
    function mintWL(uint256 numberOfTokens, bytes32[] calldata _merkleProof) 
    external
    payable
    isMintEnabled
    checkNumOfTokens(numberOfTokens)
    isCorrectPayment(MINT_PRICE, numberOfTokens)
    RIFTList(_merkleProof)
    enoughPassesRemaining(numberOfTokens)
    maxPassesPerWallet(numberOfTokens) {
        _mint(msg.sender, numberOfTokens);
    }
    /** 
     * @notice – Public Mint Function
     * @param numberOfTokens - Number of tokens to mint
     */
    function mintPublic(uint256 numberOfTokens) 
    external
    payable
    checkNumOfTokens(numberOfTokens)
    isMintEnabled
    //isCorrectPayment(MINT_PRICE, numberOfTokens)
    enoughPassesRemaining(numberOfTokens)
    maxPassesPerWallet(numberOfTokens) {
        _mint(msg.sender, numberOfTokens);
    }



 /*================= END OF MINT FUNCTIONS================== */ 


    
 /**
 *@dev Withdrawal Functions
  */
     function withdraw(address receiver) external onlyOwner{
        (bool success, ) = receiver.call{value: address(this).balance}("");
        if(success == false) revert RIFT__transferFailed();
     }

     function withdrawERC20Tokens(address _tokenAddress) external onlyOwner {
         IERC20 token = IERC20(_tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    function withdrawERC721Tokens(address _tokenAddress, uint256 tokenId) external onlyOwner {
        IERC721 token = IERC721(_tokenAddress);
        token.transferFrom(address(this), msg.sender, tokenId);
    }
}