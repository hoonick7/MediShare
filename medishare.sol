// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MediShare {
    string public name = "MediShare Token";
    string public symbol = "MDS";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 public stakeRewardRate = 5; // 5% annual reward
    uint256 public lastRewardTimestamp;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event HealthDataUploaded(uint256 indexed pid, string dataHash, address indexed uploader);
    event HealthDataPurchased(uint256 indexed pid, address indexed buyer, address indexed seller, uint256 price);
    event DataBurned(uint256 indexed pid, uint256 timestamp);
    event CoinBurned(address indexed account, uint256 value);

    struct HealthData {
        uint256 pid;
        string dataHash;
        uint256 price;
        address payable seller;
        uint256 timestamp;
    }

    mapping(uint256 => HealthData) public healthDataRecords;

    constructor() {
        lastRewardTimestamp = block.timestamp;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function uploadHealthData(uint256 pid, string memory dataHash, uint256 price) public {
        require(bytes(dataHash).length > 0, "Invalid data hash");
        healthDataRecords[pid] = HealthData({
            pid: pid,
            dataHash: dataHash,
            price: price,
            seller: payable(msg.sender),
            timestamp: block.timestamp
        });
        _mint(msg.sender, 1 * 10**uint256(decimals)); // 1 coin per upload
        emit HealthDataUploaded(pid, dataHash, msg.sender);
    }

    function purchaseHealthData(uint256 pid) public payable {
        HealthData storage data = healthDataRecords[pid];
        require(bytes(data.dataHash).length > 0, "Data does not exist");
        require(msg.value == data.price, "Incorrect price");

        uint256 sellerAmount = (msg.value * 90) / 100;
        uint256 validatorFee = msg.value - sellerAmount;

        data.seller.transfer(sellerAmount);
        // Validator fee goes to the contract owner
        payable(owner()).transfer(validatorFee);

        emit HealthDataPurchased(pid, msg.sender, data.seller, data.price);
    }

    function burnOldData() public {
        uint256 burnThreshold = 5 * 365 days; // 5 years
        for (uint256 pid = 1; pid <= totalSupply; pid++) {
            if (healthDataRecords[pid].timestamp != 0 && block.timestamp > healthDataRecords[pid].timestamp + burnThreshold) {
                delete healthDataRecords[pid];
                emit DataBurned(pid, healthDataRecords[pid].timestamp);
            }
        }
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Mint to the zero address");
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "Burn from the zero address");
        require(balanceOf[account] >= amount, "Burn amount exceeds balance");
        balanceOf[account] -= amount;
        totalSupply -= amount;
        emit CoinBurned(account, amount);
    }

    function owner() public view returns (address) {
        return msg.sender; // Simplified for this example. In production, you might want to use Ownable from OpenZeppelin.
    }

    function stake() public {
        // Stake function implementation
    }

    function claimRewards() public {
        // Claim staking rewards
    }
}
