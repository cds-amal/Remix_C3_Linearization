// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Logger {
    event Log(string s);
}

contract A is Logger {
    function foo() public virtual {
        emit Log("A.foo");
    }
}

contract B is A {
    function foo() public virtual override(A) {
        emit Log("B.foo entered");
        super.foo();
        emit Log("B.foo left");
    }
}

contract C is A {
    function foo() public virtual override(A) {
        emit Log("C.foo");
    }
}

contract Ex_02 is C, B {
    function foo() public override(B, C) {
        super.foo();
    }
}

// What does Ex_02.foo() output?
