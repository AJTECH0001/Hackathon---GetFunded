// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "solmate/src/auth/Owned.sol";
import {Time} "@openzeppelin/contracts/utils/types/Time.sol";

contract GetFunded is Owned, Time {
   
     address private immutable i_owner;
     uint256 public s_totalFunded;
     address[] private s_verifiers;

     struct Users {
          string uAddress;
          string name;
          string email;
          string id;
          string location;
          uint256 uId;
          bytes32 role;
     }

     uint256 s_userId;
     User[] s_users;

     struct Project {
          address owner;
          uint48 timeCreated;
          uint256 id;
          string title;
          string description;
          string story;
          uint256 duration;
          uint256 fundingAmount;
          ProjectType Type;
          string image;
          bool isFunded;
          mapping (uint256 => bool) public active;
          string financials;
     }

     Project[] s_projects;
     uint256 s_projectId;

     enum ProjectType {
          Technology;
          Arts;
          Education;
          Food;
          Infrastructure;
          Business;
     }

     mapping (address => User) private s_user;
     mapping(uint256 => Project) private s_project;
     mapping (uint256 => address) private idToUser;
     mapping (address => bool) private isVerifier;

     error NotUser();
     error NotVerifier();
     error AlreadyRegistered();
     error ProjectExists();
     error ZeroAddressUnAuthorized();
     error UnAuthorized();

     event Created (
          address indexed projectOwner,
          string title,
          uint256 blockTimeStamp,
          uint256 amount 
     );

     event Registered (
          address indexed user
     );

     constructor(address[] _verifiers, string calldata _role) {
          i_owner = msg.sender;

          for(uint256 i = 0, i <= _verifiers.length, i = i + 1) {
              User storage user = s_verfier[_verifiers[i]];
              user.role = keccak256(abi.encodePacked(_role));
              isVerifier[_verifiers[i]] = true;
              s_verifiers.push(user);
          }
     }
     
     modifier onlyUser() {
          if (
               msg.sender != s_user[msg.sender]
          ) revert NotUser();
          _;
     }

     modifier onlyVerifier(uint256 id) {
          User storage user = s_user[idToUser[id]]
          if (
               isVerifier[idToUser[id]] = false;
          ) revert NotVerifier();
     }

     function  getProjects() external view returns (Project[] memory) {
          return s_projects;
     }

     function removeProject(uint256 id) external only returns () {
          delete s_project[id];
     }

     function totalFunded() external view returns (uint256) {
          return s_totalFunded;
     }

     function _getCurrentTimestamp() internal view returns (uint48) {
          return Time.timestamp();
     }

     function setVerifier(string memory _role, uint256 id) public onlyOwner {
          User storage user = s_user[idToUser[id]];
          user.role = keccak256(abi.encodePacked(_role));
          s_verifiers.push(user);
          isVerifier[user] = true;
     }

     function registerUser(User calldata _user) external {
          User storage user = s_user[msg.sender];

          if (
               msg.sender == s_user[msg.sender]
          ) revert AlreadyRegistered();

          user.uAddress = msg.sender;
          user.name = _user.name;
          user.email = _user.email;
          user.id = _user.id;
          user.location = _user.location;

          user.uId = s_userId + 1;
          idToUser[user.uId] = msg.sender;

          emit Registered (
               msg.sender,
          );
     }

     function createProject(Project calldata _project) external onlyUser {
          Project storage project = s_project[s_projectId];

          if(
               projectCreated[s_projectId]
          ) revert ProjectExists();
          if(
               msg.sender == address(0)
          ) revert ZeroAddressUnAuthorized();
          if(
               isVerifier[msg.sender] = true
          ) revert UnAuthorized();

          project.title = _project.title;
          project.description = _project.description;
          project.owner = msg.sender;
          project.story = _project.story;
          project.timeCreated = _getCurrentTimestamp();
          project.duration = _project.duration;
          project.fundingAmount = _project.fundingAmount;
          project.Type = _project.Type;
          project.image = _project.image;
          project.isFunded = false;
          project.financials = _project.financials;

          project.id = s_projectId + 1;

          project.active[project.id] = true;

          emit Created {
               msg.sender,
               project.title,
               project.timeCreated,
               project.fundingAmount
          }
     }

}
