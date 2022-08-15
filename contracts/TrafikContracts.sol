
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./libraries/Base64.sol";

import {DataTypes} from "./DataTypes.sol";

contract TRafik is ERC721, Ownable {

    mapping(uint256 => DataTypes.Validator) public validators;
    mapping(uint256 => DataTypes.Report) public pendingReports;
    mapping(uint256 => DataTypes.Report) public approvedReports;
    mapping(uint256 => DataTypes.Report) public rejectedReports;
    mapping(uint256 => bool) public isApproved;
    mapping(uint256 => bool) public isRejected;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _reportIds;

    constructor() ERC721("TRafik", "TRFK") {
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        DataTypes.Validator memory validatorAttributes = validators[
            _tokenId
        ];

        string
            memory coverPicture = "";
        string memory validated = Strings.toString(validatorAttributes.validated);

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                         '{"TRafik Validator": "'
                        ,
                        validatorAttributes.department
                        ,'","Validator ID: "',
                        Strings.toString(_tokenId),
                        '", "description": "Validator", "image": "',
                        coverPicture,
                        '","attributes": [ { "trait_type": "Validated", "value": ',
                        validated,
                        '}, } ]}'
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        
        return output;
    }

    function mintValidatorNFT(string memory _department, string memory _location)
        external isPrivileged
    {
        uint256 newValidatorId = _tokenIds.current();
        _safeMint(msg.sender, newValidatorId);
        
        DataTypes.Validator memory newValidator = DataTypes.Validator({
            validatorId: newValidatorId,
            department: _department,
            location: _location,
            validated: 0
        });

        validators[newValidatorId] = newValidator;
        _tokenIds.increment();
    }

    modifier isPrivileged() {
        require(msg.sender == owner() || balanceOf(msg.sender) == 1, "Not privileged");
        _;
    }

    function addReport(string memory _title, string memory _violationType, string memory _photo, string memory _video, string memory _registrationPlate, string memory _violationLocation, string memory _violationDate, string memory _description) public {
        uint256 reportId = _reportIds.current();
        DataTypes.Report memory newReport = DataTypes.Report({
            violationType: _violationType,
            title: _title,
            video: _video,
            photo: _photo,
            registrationPlate: _registrationPlate,
            violationDate: _violationDate,
            description: _description,
            violationLocation: _violationLocation,
            reporter: msg.sender,
            dateOfReport: block.timestamp
        });
        pendingReports[reportId] = newReport;
        _reportIds.increment();
    }

    function approveReport(uint256 _reportId) public isPrivileged {
        if (isApproved[_reportId] || isRejected[_reportId]) {
            revert("This report is no longer in pending");
        }
        DataTypes.Report memory approvedReport = pendingReports[_reportId];
        approvedReports[_reportId] = approvedReport;
        isApproved[_reportId] = true;
        delete pendingReports[_reportId];
    }

    function rejectReport(uint256 _reportId) public isPrivileged {
        if (isApproved[_reportId] || isRejected[_reportId]) {
            revert("This report is no longer in pending");
        }
        DataTypes.Report memory rejectedReport = pendingReports[_reportId];
        rejectedReports[_reportId] = rejectedReport;
        isRejected[_reportId] = true;
        delete pendingReports[_reportId];
    }
}