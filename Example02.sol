// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Logger {
    event Log(string s);
}

contract A is Logger {
    // [3] emit "A.foo"
    function foo() public virtual {
        emit Log("A.foo");
    }
}

contract B is A {
    // [2] super.foo() in the context of B refers to the next contract in
    // the linearization order, which is A.
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

// Lin: Ex_02, B, C, A, Logger
contract Ex_02 is C, B {
    // [1] super.foo() in the context of Ex_02 refers to the next contract in
    // the linearization order, which is B.
    function foo() public override(C, B) {
        super.foo();                      // Output:
                                          //   B.foo entered
                                          //   C.foo
                                          //   B.foo left
    }
}

// Linearization
// L(A) = [A] + Merge(L(Logger), [Logger])
//      = [A] + Merge([Logger], [Logger])
//      = [A, Logger]

// L(B) = [B] + Merge(L(A), [A])
//      = [B] + Merge([A, Logger], [A])
//      = [B, A] + Merge([Logger], [])
//      = [B, A, Logger]

// L(C) = [C] + Merge(L(A), [A])
//      = [C] + Merge([A, Logger], [A])
//      = [C, A] + Merge([Logger], [])
//      = [C, A, Logger]


// L(Ex_02) = [Ex_02] + Merge(L(B), L(C), [B,C])                   // Order from Right to left (Ex_02 is C, B), 
//                                                                    therefore B,C is the correct order.
//      = [Ex_02] + Merge([B, A, Logger], [C, A, Logger], [B, C])  // Try B, it works!
//      = [Ex_02, B] + Merge([A, Logger], [C, A, Logger], [C])     // Try A, Logger fails! C, works!
//      = [Ex_02, B, C] + Merge([A, Logger], [A, Logger], [])      // Try A, it works! Logger left!
//      = [Ex_02, B, C, A, Logger] 
