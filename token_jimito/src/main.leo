// The 'token_jimito' program.
program token_jimito.aleo {
      // The `Token` record datatype.
    record Token {
        // The token owner.
        owner: address,
        // The token amount.
        amount: u64,
    }

    // The `mint` function initializes a new record with the
    // specified number of tokens assigned to the caller.
    transition mint(amount: u64) -> Token {
        return Token {
            owner: self.caller,
            amount: amount,
        };
    }

    // The `transfer` function sends the specified number of tokens
    // to the receiver from the provided token record.
    transition transfer(token: Token, to: address, amount: u64) -> (Token, Token) {
        // Checks the given token record has sufficient balance.
        // This `sub` operation is safe, and the proof will fail
        // if an overflow occurs.
        // `difference` holds the change amount to be returned to sender.
        let difference: u64 = token.amount - amount;

        // Produce a token record with the change amount for the sender.
        let remaining: Token = Token {
            owner: token.owner,
            amount: difference,
        };

        // Produce a token record for the specified receiver.
        let transferred: Token = Token {
            owner: to,
            amount: amount,
        };

        // Output the sender's change record and the receiver's record.
        return (remaining, transferred);
    }

    transition balance_of(owner_balance: Token) -> u64 {
        let amount_balance: u64 = owner_balance.amount;
        let minimun: u64 = 0u64;
        let return_balance:u64 = 0u64;
        if amount_balance >= minimun{
            return_balance = amount_balance;
        }
        return return_balance;
    }
}