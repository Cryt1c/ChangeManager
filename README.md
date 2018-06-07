# ChangeManager

This framework presents smart contracts for the construction business to suggest, select and track changes. It includes
the smart contracts and tests to ensure their correct functionality.

## Installation

1. Install truffle globally.
    ```javascript
    npm install -g truffle
    ```

2. Install dependencies of ChangeManager.
    ```javascript
    npm install
    ```

3. Run the development console.
    ```javascript
    truffle develop
    ```

4. Compile and migrate the smart contracts. Note inside the development console we don't preface commands with `truffle`.
    ```javascript
    compile
    migrate
    ```

5. Truffle can run tests written in Solidity or JavaScript against your smart contracts. Note the command varies slightly if you're in or outside of the development console.
  ```javascript
  // If inside the development console.
  test

  // If outside the development console..
  truffle test
  ```

