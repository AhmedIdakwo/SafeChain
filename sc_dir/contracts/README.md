# SafeChain Escrow Contract

SafeChain Escrow is a secure, trustless escrow service implemented as a smart contract. It provides a robust platform for facilitating transactions between buyers and sellers with built-in dispute resolution capabilities.

## Features

- **Trustless Escrow**: Facilitates secure transactions without the need for a traditional trusted third party.
- **Dispute Resolution**: Built-in mechanism for handling disputes with an assigned resolver.
- **State Management**: Clearly defined states for each stage of the escrow process.
- **Role-based Actions**: Different functions for buyers, sellers, and dispute resolvers.
- **Read-only Status Checks**: Ability to check the status of any escrow transaction.

## Contract States

1. `STATE-INITIATED` (0): Escrow has been created but not yet funded.
2. `STATE-FUNDED` (1): Buyer has funded the escrow.
3. `STATE-COMPLETED` (2): Transaction completed successfully, funds released to seller.
4. `STATE-DISPUTED` (3): Buyer has initiated a dispute.
5. `STATE-REFUNDED` (4): Funds have been refunded to the buyer (post-dispute resolution).

## Public Functions

1. `create-escrow`: Initiates a new escrow transaction.
2. `fund-escrow`: Allows the buyer to fund an initiated escrow.
3. `complete-escrow`: Marks the escrow as completed and releases funds to the seller.
4. `initiate-dispute`: Allows the buyer to raise a dispute.
5. `resolve-dispute`: Allows the assigned dispute resolver to settle a dispute.
6. `get-escrow-status`: A read-only function to check the status of an escrow.

## Usage

### Creating an Escrow

```clarity
(contract-call? .safechain-escrow create-escrow 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM u1000)
```

### Funding an Escrow

```clarity
(contract-call? .safechain-escrow fund-escrow u0)
```

### Completing an Escrow

```clarity
(contract-call? .safechain-escrow complete-escrow u0)
```

### Initiating a Dispute

```clarity
(contract-call? .safechain-escrow initiate-dispute u0 "Item not as described" 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
```

### Resolving a Dispute

```clarity
(contract-call? .safechain-escrow resolve-dispute u0 true)
```

### Checking Escrow Status

```clarity
(contract-call? .safechain-escrow get-escrow-status u0)
```

## Error Codes

- `ERR-UNAUTHORIZED` (u1): Action not allowed for the current user.
- `ERR-INVALID-STATE` (u2): Action not allowed in the current escrow state.
- `ERR-INSUFFICIENT-FUNDS` (u3): Not enough funds to perform the action.
- `ERR-DISPUTE-NOT-FOUND` (u4): The specified escrow does not exist.
- `ERR-INVALID-AMOUNT` (u5): The specified amount is not valid.
- `ERR-INVALID-ESCROW-ID` (u6): The specified escrow ID is not valid.

## Security Considerations

- The contract owner cannot act as a seller to prevent potential conflicts of interest.
- Only the buyer can fund, complete, or initiate a dispute for an escrow.
- Only the assigned dispute resolver can resolve a dispute.
- The contract uses clearly defined states to prevent unauthorized actions.

## Future Improvements

1. Implement a time-lock feature for automatic completion or refund after a certain period.
2. Add support for partial refunds in dispute resolution.
3. Implement a rating system for buyers, sellers, and dispute resolvers.
