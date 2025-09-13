# 🏗️ Infrastructure Voting DAO

[![Clarity Smart Contract](https://img.shields.io/badge/Clarity-Smart%20Contract-blue.svg)](https://clarity-lang.org/)
[![Stacks Blockchain](https://img.shields.io/badge/Stacks-Blockchain-orange.svg)](https://stacks.co/)

> **Empowering communities to collectively fund and manage infrastructure projects through transparent governance** 🌍

## 📋 Overview

The Infrastructure Voting DAO is a decentralized autonomous organization built on the Stacks blockchain that enables communities to pool funds, propose infrastructure projects, and vote on funding allocation. The contract implements milestone-based fund release to ensure accountability and transparent resource management.

## ✨ Key Features

- 🏛️ **Democratic Governance**: Community members vote on infrastructure proposals
- 💰 **Transparent Treasury**: Public tracking of fund contributions and allocations  
- 🎯 **Milestone-Based Funding**: Progressive fund release tied to project milestones
- 👥 **Membership System**: Join the DAO to participate in voting and funding
- 📊 **Comprehensive Tracking**: Full audit trail of proposals, votes, and fund movements
- 🔒 **Secure Fund Management**: Smart contract-controlled treasury with member protections

## 🛠️ Contract Functions

### Member Management
- `join-dao()` - Join the DAO as a voting member
- `contribute-funds(amount)` - Add STX to the DAO treasury
- `withdraw-contribution(amount)` - Withdraw your contributed funds
- `is-member(user)` - Check if a user is a DAO member

### Proposal System  
- `create-proposal(title, description, budget)` - Submit new infrastructure proposals
- `vote-on-proposal(proposal-id, support)` - Vote yes/no on active proposals
- `finalize-proposal(proposal-id)` - Finalize voting results after period ends
- `get-proposal(proposal-id)` - Get detailed proposal information

### Milestone Management
- `create-milestone(proposal-id, description, amount)` - Create project milestones
- `vote-milestone(milestone-id, approve)` - Vote to approve/reject milestone completion
- `release-milestone-funds(milestone-id)` - Release funds for approved milestones

### Data Access
- `get-dao-stats()` - Get DAO treasury and membership statistics
- `get-milestone(milestone-id)` - Get milestone details and voting status
- `get-vote(proposal-id, voter)` - Check how a specific member voted

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Node.js](https://nodejs.org/) for running tests

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/Infrastructure-Voting-DAO.git
cd Infrastructure-Voting-DAO
```

2. Install dependencies:
```bash
npm install
```

3. Run contract checks:
```bash
clarinet check
```

4. Run tests:
```bash
npm test
```

## 💡 Usage Examples

### 1. Joining the DAO and Contributing 💪
```clarity
;; Join the DAO
(contract-call? .Infrastructure-Voting-DAO join-dao)

;; Contribute 1000 STX to the treasury
(contract-call? .Infrastructure-Voting-DAO contribute-funds u1000000000)
```

### 2. Creating an Infrastructure Proposal 📝
```clarity
(contract-call? .Infrastructure-Voting-DAO create-proposal 
  "Community Water System"
  "Install new water pumps and distribution system for the neighborhood"
  u5000000000) ;; 5000 STX budget
```

### 3. Voting on Proposals 🗳️
```clarity
;; Vote YES on proposal #1
(contract-call? .Infrastructure-Voting-DAO vote-on-proposal u1 true)

;; Vote NO on proposal #2  
(contract-call? .Infrastructure-Voting-DAO vote-on-proposal u2 false)
```

### 4. Managing Project Milestones 🎯
```clarity
;; Create a milestone for proposal #1
(contract-call? .Infrastructure-Voting-DAO create-milestone 
  u1 
  "Purchase and install water pumps"
  u2000000000) ;; 2000 STX for this milestone

;; Approve milestone completion
(contract-call? .Infrastructure-Voting-DAO vote-milestone u1 true)

;; Release funds after milestone approval
(contract-call? .Infrastructure-Voting-DAO release-milestone-funds u1)
```

## 🔧 Configuration

The contract includes several configurable parameters:

- **Voting Period**: `1440` blocks (approximately 24 hours)
- **Quorum Threshold**: `51%` approval required
- **Minimum Participation**: `30%` of members must vote for quorum

## 📊 DAO Governance Model

### Proposal Lifecycle
1. **📝 Creation**: Members submit proposals with title, description, and budget
2. **🗳️ Voting**: 24-hour voting period for all DAO members  
3. **✅ Finalization**: Automatic approval if quorum met and >51% support
4. **🎯 Milestones**: Approved projects broken into funded milestones
5. **💰 Execution**: Progressive fund release as milestones complete

### Voting Requirements
- Only DAO members can vote
- One vote per member per proposal
- Quorum requires 30% member participation
- Majority (51%+) needed for approval

## 🔒 Security Features

- ✅ Member-only voting and proposal creation
- ✅ Single vote per member per proposal enforcement  
- ✅ Treasury fund protection with withdrawal limits
- ✅ Milestone-based fund release prevents bulk misuse
- ✅ Time-locked voting periods prevent rushed decisions

## 🧪 Testing

Run the complete test suite:
```bash
npm test
```

Test individual components:
```bash
clarinet test tests/Infrastructure-Voting-DAO.test.ts
```

## 📈 Deployment

### Devnet Deployment
```bash
clarinet deploy --devnet
```

### Testnet Deployment  
```bash
clarinet deploy --testnet
```

### Mainnet Deployment
```bash
clarinet deploy --mainnet
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`  
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Impact

This DAO empowers communities to:
- 🏘️ **Take ownership** of local infrastructure needs
- 💡 **Reduce corruption** through transparent fund management
- 🎯 **Ensure accountability** with milestone-based project tracking  
- 🤝 **Build consensus** through democratic decision-making
- 📊 **Create transparency** in public resource allocation

## 📞 Support

For questions, issues, or contributions:
- 🐛 Report bugs via [GitHub Issues](https://github.com/yourusername/Infrastructure-Voting-DAO/issues)
- 💬 Join our [Discord community](https://discord.gg/yourinvite)
- 📧 Email: support@yourproject.com

---

**Built with ❤️ for stronger communities and transparent governance**
