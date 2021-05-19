// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SwarmFaucet is Initializable, AccessControlUpgradeable {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant FUNDER_ROLE = keccak256("FUNDER_ROLE");

    IERC20 private _token;

    uint256 private _bzzAmount;
    uint256 private _ethAmount;

    mapping(address => bool) funded;

    event Funded(address addr, FundState state);

    enum FundState {SUCCESS, FAILURE, ALREADY_FUNDED}

    function initialize(
        IERC20 __token,
        uint256 __ethAmount,
        uint256 __bzzAmount
    ) public initializer {
        __AccessControl_init_unchained();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _token = __token;
        _ethAmount = __ethAmount;
        _bzzAmount = __bzzAmount;
    }

    function token() public view virtual returns (IERC20) {
        return _token;
    }

    function ethAmount() public view virtual returns (uint256) {
        return _ethAmount;
    }

    function bzzAmount() public view virtual returns (uint256) {
        return _bzzAmount;
    }

    function setToken(IERC20 newToken) public onlyRole(ADMIN_ROLE) {
        _token = newToken;
    }

    function setBzzAmount(uint256 amount) public onlyRole(ADMIN_ROLE) {
        _bzzAmount = amount;
    }

    function setEthAmount(uint256 amount) public onlyRole(ADMIN_ROLE) {
        _ethAmount = amount;
    }

    function withdraw(IERC20 from, uint256 amount) public onlyRole(ADMIN_ROLE) {
        from.transfer(
            msg.sender,
            amount > 0 ? amount : from.balanceOf(address(this))
        );
    }

    function withdrawBzz(uint256 amount) public onlyRole(ADMIN_ROLE) {
        withdraw(_token, amount);
    }

    function withdrawEth(uint256 amount) public onlyRole(ADMIN_ROLE) {
        payable(msg.sender).transfer(
            amount > 0 ? amount : address(this).balance
        );
    }

    function fund(address payable[] memory addresses)
        public
        onlyRole(FUNDER_ROLE)
    {
        for (uint256 i = 0; i < addresses.length; i++) {
            FundState state = FundState.SUCCESS;

            if (funded[addresses[i]]) {
                state = FundState.ALREADY_FUNDED;
            } else if (
                !addresses[i].send(_ethAmount) ||
                !_token.transfer(addresses[i], _bzzAmount)
            ) {
                state = FundState.FAILURE;
            } else {
                funded[addresses[i]] = true;
            }

            emit Funded(addresses[i], state);
        }
    }

    function resetFunded(address user) public onlyRole(FUNDER_ROLE) {
        funded[user] = false;
    }

    function wasFunded(address user) public view returns (bool) {
        return funded[user];
    }

    receive() external payable {}

    fallback() external payable {}
}
