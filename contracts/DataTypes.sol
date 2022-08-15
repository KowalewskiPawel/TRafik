// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity ^0.8.0;

library DataTypes {

    struct Validator {
        uint256 validatorId;
        string location;
        string department;
        uint256 validated;
    }

    struct Report {
        string title;
        string violationType;
        string photo;
        string video;
        string registrationPlate;
        string violationLocation;
        string violationDate;
        string description;
        address reporter;
        uint dateOfReport;
    }
}