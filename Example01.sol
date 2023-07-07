// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract A {
    function foo() public         pure returns (uint) { 
      // [2] bar does not exist in A, so it will try to find it in the
      // parent contracts following the linearization order: A -> B -> Ex_01,
      // which leads to Ex_01::bar().
      return bar(); 
    }

    function bar() public virtual pure returns (uint) { return 1; }
}

contract B is A { }

contract Ex_01 is B {
    function main() public pure returns (uint) { 
      // [1] foo does not exist in Ex_01, so it will try to find it in the
      // parent contracts following the linearization order: Ex_01 -> B -> A,
      // which leads to A::foo() as the first foo() found.
      return foo(); 
    }

    // [3] Linearization from [2] leads here, which returns 2!
    function bar() public override pure returns (uint) { 
      return 2; 
    }
}

// Q: What is the outcome of Ex_01.main()?

// Linearization:
// L(A) = [A]

// L(B) = [B] + merge(L(A), [A])
//      = [B] + merge([A], [A])
//      = [B, A] + merge([], [])
//      = [B, A] 

// L(Ex_01) = [Ex_01] + merge(L(B), [B])
//          = [Ex_01] + merge([B, A], [B])      // B works
//          = [Ex_01, B] + merge([A], [])       // A works
//          = [Ex_01, B, A] + merge([], [])
//          = [Ex_01, B, A]
