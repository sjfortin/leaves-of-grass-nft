pragma solidity 0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
  // So, we make a baseSvg variable here that all our NFTs can use.
  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  // I create three arrays, each with their own theme of random words.
  // Pick some random funny words, names of anime characters, foods you like, whatever! 
  string[] firstWords = ["MODERN", "PHANTOM", "BOUNDLESS", "VISIBLE", "PUZZLE", "MYRIADS"];
  string[] secondWords = ["NATURE", "TREES", "MOUNTAIN", "RIVER", "OCEAN", "VALLEY"];
  string[] thirdWords = ["KOSMOS", "DREAM", "FIRE", "LEAVES", "GRASS", "SHIPS"];

	event NewEpicNFTMinted(address sender, uint256 tokenId);

  constructor() ERC721 ("SquareNFT", "SQUARE") {
    console.log("This is my NFT contract. Woah!");
  }

	function pickRandomWord(uint256 tokenId, string memory wordType) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(wordType, Strings.toString(tokenId))));

    if (keccak256(abi.encodePacked(wordType)) == keccak256(abi.encodePacked("FIRST_WORD"))) {
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
				rand = rand % firstWords.length;
				return firstWords[rand];
    } else if (keccak256(abi.encodePacked(wordType)) == keccak256(abi.encodePacked("SECOND_WORD"))) {
				rand = rand % secondWords.length;
				return secondWords[rand];
		} else if (keccak256(abi.encodePacked(wordType)) == keccak256(abi.encodePacked("THIRD_WORD"))) {
				rand = rand % thirdWords.length;
				return thirdWords[rand];
		} else {
				return "DEFAULT_WORD";
		}
  }

  function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }

	function getTotalMints() public view returns (uint256) {
    return _tokenIds.current();
	}

	uint256 maxMintable = 49; // remember we are zero based, so we actually have 3!

  function makeAnEpicNFT() public {
    uint256 newItemId = _tokenIds.current();

		require(newItemId <= maxMintable, "The maximum number of NFTs has been reached.");

    // We go and randomly grab one word from each of the three arrays.
    string memory first = pickRandomWord(newItemId, "FIRST_WORD");
    string memory second = pickRandomWord(newItemId, "SECOND_WORD");
    string memory third = pickRandomWord(newItemId, "THIRD_WORD");
		string memory combinedWord = string(abi.encodePacked(first, second, third));

		string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

		    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

    _safeMint(msg.sender, newItemId);
    
    // Update your URI!!!
    _setTokenURI(newItemId, finalTokenUri);
  
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

		// EMIT MAGICAL EVENTS.
    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}