// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract ProjectCrowddy {
   
   address private owner;

   struct Project {
        uint256 projectId;
        string title;
        string description;
        address owner;
        string projectStory;
        uint256 timeCreated;
        uint256 duration;
        uint256 totalFunded;
        ProjectType projectType;
        string image;
        bool isFunded;
   }

   enum ProjectType {
        Technology;
        Arts;
        Education;
        Food;
        Infrastructure;
        Business;
   }

   Project[] s_projects;

   mapping(uint256 => Project) private s_project;
   mapping (uint256 => bool) private projectCreated;

   constructor() {
    owner = msg.sender;
   }

   function createProject(Project calldata _project) external {
        Project storage project = s_project[_project.projectId];

        if(projectCreated[project.projectId]) revert ProjectCreated();
        if(msg.sender == address(0)) revert ZeroAddressUnAuthorized();

        project.title = _project.title;
        project.description = _project.description;
        project.owner = msg.sender;
        project.projectStory = _project.projectStory;
        project.timeCreated = block.timestamp;
        project.duration = _project.duration;
        project.totalFunded = _project.totalFunded;
        project.projectType = _project.projectType;
        project.image = _project.image;
        project.isFunded = false;

        project.projectId = project.projectId + 1;

        projectCreated[project.projectId] = true;

        emit Created {
            msg.sender,
            project.title
        }
   }

   function  getProjects() external view returns (Project[] memory) {
        return s_projects;
   }

   function removeProject(uint256 id) external only returns () {
    
   }
}
