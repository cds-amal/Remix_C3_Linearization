// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract A {
    function foo() public         pure returns (uint) { return bar(); }
    function bar() public virtual pure returns (uint) { return 1; }
}

contract B is A { }

contract Ex_01 is B {
    function main() public pure returns (uint) { return foo(); }
    function bar() public override pure returns (uint) { return 2; }
}

// Q: What is the outcome of c.main()?
