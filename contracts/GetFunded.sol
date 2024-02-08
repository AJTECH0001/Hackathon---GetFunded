// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

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
     mapping (uint256 => uint256) private s_idToActive;
     mapping(uint => mapping(address => uint))private s_investorsBalance;
    `mapping(address => bool) private s_hasInvested;

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
     }

     modifier activeTime(uint _Id) {
          Project storage project = s_project[id];
        if(
          _getCurrentTimestamp() <= (s_idToActive[_Id].duration)
          ) revert NotActive();
        if(
          project.active
        ) revert NotActive();
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

          emit Registered (
               msg.sender,
          );
     }

     function createProject(Project calldata _project) external onlyUser {
          Project storage project = s_project[s_projectId];

          if(
               project.active[project.id] = true;
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

          s_projects.push(project);

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

          project.fundingAmount += msg.value;
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
        uint _CampaignId
     ) external returns (string memory) {
          Campaign storage campaign = mapCampaign[_CampaignId];
          require(
            campaign.duration < block.timestamp,
            "time e o yi pe, pada wa "
          );
          require(
            campaign.campaignBalance < campaign.fundingGoal,
            "campaign goal reached"
          );
          require(
            contributorBalance[CampaignId][msg.sender] > 0,
            "you do not have money in this campaign"
          );
          campaign.isActive = false;
          string memory successMessage;

          for (uint i = 0; i < campaign.contributors.length; i++) {
            if (campaign.contributors[i] == msg.sender) {
                address contributor = campaign.contributors[i];
                uint userBalance = contributorBalance[_CampaignId][msg.sender];
                payable(contributor).transfer(userBalance);
                contributorBalance[_CampaignId][
                    contributor
                ] -= contributorBalance[_CampaignId][msg.sender];
                campaign.campaignBalance -= userBalance;
            }
          }
          return (successMessage = "Sorry we have to refund, goal not reached");
     }

     function payCampaignOwner(uint _CampaignId) public returns (string memory) {
          Campaign storage campaign = mapCampaign[_CampaignId];
          require(
               campaign.campaignBalance >= campaign.fundingGoal,
               "goal not reached"
          );
          require(campaign.isActive, "campaign is not active");
          string memory successMessage;
          address owner = campaign.campaignOwner;
          payable(owner).transfer(campaign.campaignBalance);
          campaign.campaignBalance = 0;
          campaign.isActive = false;
          return (successMessage = "Congratulations");
     }
}
