// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HelloListToBid {
    string public message;


constructor(string memory newMessage) {

        message = newMessage;
    }

    function setMessage(string calldata newMessage) external {
        message = newMessage;
    }

    struct Listing {
        uint id;
        address seller;
        string title;
        uint topBid;
        address topBidder;
        bool fulfilled;
    }

    mapping(uint => Listing) public listings;
    uint public nextListingId;

    event BidPlaced(uint indexed listingId, address indexed bidder, uint amount);
    event FinalJudgment(uint indexed listingId, address indexed seller, address indexed buyer);

    function createListing(string memory title) external {
        listings[nextListingId] = Listing({
            id: nextListingId,
            seller: msg.sender,
            title: title,
            topBid: 0,
            topBidder: address(0),
            fulfilled: false
        });
        nextListingId++;
    }

    function placeBid(uint listingId) external payable {
        Listing storage l = listings[listingId];
        require(!l.fulfilled, "Listing fulfilled");
        require(msg.value > l.topBid, "Bid too low");

        if (l.topBidder != address(0)) {
            payable(l.topBidder).transfer(l.topBid);
        }

        l.topBid = msg.value;
        l.topBidder = msg.sender;

        emit BidPlaced(listingId, msg.sender, msg.value);
    }

    function finalizeListing(uint listingId) external {
        Listing storage l = listings[listingId];
        require(msg.sender == l.seller, "Only seller can finalize");
        require(!l.fulfilled, "Already fulfilled");

        l.fulfilled = true;
        payable(l.seller).transfer(l.topBid);

        emit FinalJudgment(listingId, l.seller, l.topBidder);
    }
}
