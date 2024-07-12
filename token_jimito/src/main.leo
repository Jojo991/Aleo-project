// The 'token_jimito' program.
program token_jimito.aleo {
      // Step one: Define an onchain token balance tracking variable.
	mapping account: address => u64;

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

		// The `balance_of` function returns the balance of a particular owner address.
		transition balance_of(owner_balance: Token) -> u64 {
			let amount_balance: u64 = owner_balance.amount;
			let minimum: u64 = 0u64;
			let return_balance: u64 = 0u64;
			if amount_balance >= minimum {
				return_balance = amount_balance;
			}
			return return_balance;
		}
			// The function `mint_public` issues the specified token amount for the token receiver publicly on the network.
		transition mint_public(public receiver: address, public amount: u64) {
			// Mint the tokens publicly by invoking the computation on-chain.
			return then finalize(receiver, amount);
		}

		finalize mint_public(public receiver: address, public amount: u64) {
			// Increment `account[receiver]` by `amount`.
			let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
			Mapping::set(account, receiver, receiver_amount + amount);
		}

		transition transfer_public(public receiver: address, public amount: u64) {
			// Transfer the tokens publicly, by invoking the computation on-chain.
			return then finalize(self.caller, receiver, amount);
		}

		finalize transfer_public(public sender: address, public receiver: address, public amount: u64) {
		// Decrement `account[sender]` by `amount`.
		let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
		Mapping::set(account, sender, sender_amount - amount);

		// Increment `account[receiver]` by `amount`.
		let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
		Mapping::set(account, receiver, receiver_amount + amount);
		}
		// Rename the functions from chap.4 with "private" keywords
	transition mint_private(receiver: address, amount: u64) -> token {
		return token {
			owner: receiver,
			amount: amount,
		};
	}

	transition transfer_private(sender: token, receiver: address, amount: u64) -> (token, token) {
		// Checks the given token record has sufficient balance.
		let difference: u64 = sender.amount - amount;

		// Produce a token record with the change amount for the sender.
		let remaining: token = token {
			owner: sender.owner,
			amount: difference,
		};

		// Produce a token record for the specified receiver.
		let transferred: token = token {
			owner: receiver,
			amount: amount,
		};

		// Output the sender's change record and the receiver's record.
		return (remaining, transferred);
	}

	// Define conversion functions

	// Public to private function
	transition transfer_public_to_private(public receiver: address, public amount: u64) -> token {
		// Produces a token record for the token receiver.
		let transferred: token = token {
			owner: receiver,
			amount: amount,
		};

		// Output the receiver's record.
		return transferred then finalize(self.caller, amount);
	}

	finalize transfer_public_to_private(public sender: address, public amount: u64) {
		// Decrements `account[sender]` by `amount`.
		let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
		Mapping::set(account, sender, sender_amount - amount);
	}

	// Private to public function
	transition transfer_private_to_public(sender: token, public receiver: address, public amount: u64) -> token {
		// Checks the given token record has a sufficient token amount.
		let difference: u64 = sender.amount - amount;

		// Produces a token record with the change amount for the caller.
		let remaining: token = token {
			owner: sender.owner,
			amount: difference,
		};

		// Output the sender's change record.
		return remaining then finalize(receiver, amount);
	}

	finalize transfer_private_to_public(public receiver: address, public amount: u64) {
		// Increment `account[receiver]` by `amount`.
		let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
		Mapping::set(account, receiver, receiver_amount + amount);
	}
}