// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

/*@title: GetFunded
@author: Paul
@notice: This project is a platform that allows anyoone with a project idea to raise funds 
through retail funding, each project is checked against the criteria of 
@dev: implements */

import "solmate/src/auth/Owned.sol";
import "@openzeppelin/contracts/utils/types/Time.sol";

contract GetFunded is Owned {
   
     address private immutable i_owner;
     uint256 public s_totalFunded;
     address[] private s_verifiers;
     uint256 s_burnFee;

     struct Users {
          address uAddress;
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
          uint256 amountFunded;
          uint256 fundingBalance;
          ProjectType Type;
          string image;
          bool isFunded;
          mapping (uint256 => bool) public active;
          string financials;
          address[] investors;
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
     mapping (uint256 => Project) private s_project;
     mapping (uint256 => address) private idToUserAddress;
     mapping (address => bool) private isVerifier;
     mapping (uint => mapping(address => uint))private s_investorsBalance;
    `mapping (address => bool) private s_hasInvested;

     error InvalidUser();
     error NotVerifier();
     error AlreadyRegistered();
     error ProjectExists();
     error ZeroAddressUnAuthorized();
     error UnAuthorized();
     error NotInvested();

     event Created (
          address indexed projectOwner,
          string title,
          uint256 blockTimeStamp,
          uint256 amount 
     );

     event Registered (
          address indexed user
     );

     event Funded(
          uint256 indexed id,
          address indexed owner,
          uint256 indexed fundingAmount
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
               msg.sender != s_user[msg.sender].uAddress
          ) revert InvalidUser();
          if (
               msg.sender == address(0);
          ) revert InvalidUser();
          _;
     }

     modifier onlyVerifier(uint256 id) {
          if (
               isVerifier[idToUser[id]] = false;
          ) revert NotVerifier();
          _;
     }

     function  getProjects() external view returns (Project[] memory) {
          return s_projects;
     }

     function getProjectById(uint256 id) public view returns (Project memory) {
          return s_project[id];
     }

     function removeProject(uint256 id) external only returns () {
          delete getProjectById(id);
     }

     function totalFunded() external view returns (uint256) {
          return s_totalFunded;
     }

     function _getCurrentTimestamp() internal view returns (uint48) {
          return Time.timestamp();
     }

     function getInvestors(uint256 id) external view returns (address[] memory) {
          Project storage project = s_project[id];
          return project.investors;
     }

     function getUsers() external view returns (Users[] memory) {
          return s_users;
     }

     function getInvestorsBalance(uint256 _projectid) external view returns (uint256) {
          reuturn s_investorsBalance[_projectId][msg.sender];
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
               msg.sender == s_user[msg.sender].uAddress
          ) revert AlreadyRegistered();

          user.uAddress = msg.sender;
          user.name = _user.name;
          user.email = _user.email;
          user.id = _user.id;
          user.location = _user.location;

          user.uId = s_userId + 1;
          idToUser[user.uId] = msg.sender;

          s_users.push(user);

          emit Registered (
               msg.sender,
          );
     }

     function createProject(Project calldata _project) external onlyUser returns(uint256){
          Project storage project = s_project[s_projectId];

          if(
               project.active[project.id]
          ) revert ProjectExists();

          if(
               msg.sender == address(0)
          ) revert ZeroAddressUnAuthorized();

          if(
               isVerifier[msg.sender]
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

          s_projects.push(project);

          return project.id;

          emit Created {
               msg.sender,
               project.title,
               project.timeCreated,
               project.fundingAmount
          }
     }

     function fundProject(
        uint _projectId
     ) public payable onlyUser activeTime(_projectId) {
          Project storage project = s_project[_projectId];

          if(
               _getCurrentTimestamp() > project.duration
          ) revert NotActive();

          if(
               !hasInvested[msg.sender]
          ) revert NotInvested();

          if(
               isVerifier[msg.sender]
          ) revert UnAuthorized();

          project.amountFunded += msg.value;
          project.fundingBalance = project.fundingAmount - msg.value;
          s_investorsBalance[_projectId][msg.sender] += msg.value;
          project.investors.push(msg.sender);
          s_hasInvested[msg.sender] = true;

          emit Funded (
               _projectId,
               msg.sender,
               msg.value
          );
     }

     function refundInvestors(
        uint _projectId
     ) external onlyOwner returns (bool success) {
          Project storage project = s_project[_projectId];
          if(
            project.duration > _getCurrentTimestamp();
          ) revert TimeNotReached();

          if(
            project.fundingBalance > 0
          ) revert goalReached();

          if(
            !s_hasInvested[msg.sender]
          ) revert UnAuthorized();

          project.isActive[_projectId] = false;

          for (uint i = 0; i < project.investors.length; i++) {
            if (project.investors[i] == msg.sender) {
                address investor = project.investors[i];
                uint userBalance = s_investorsBalance[_projectId][msg.sender];
                payable(investor).transfer(userBalance);
                s_investorsBalance[_projectId][investor] -= s_investorsBalance[_projectId][msg.sender];
                project.amountFunded -= userBalance;
            }
          }
          return (successs = true);
     }

     function payProjectCreator(uint _projectId) external onlyOwner returns (bool success) {
          Project storage project = s_project[_projectId];
          require(
               project.fundingBalance >= project.fundingAmount,
               "goal not reached"
          );
          require(project.isActive[_projectId], "campaign is not active");
          address owner = project.owner;
          payable(owner).transfer(project.fundingBalance);
          project.fundingBalance = 0;
          project.isActive[_projectId] = false;
          return (success = true);
     }
}
