use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use zeroable::Zeroable;
use array::{ArrayTrait, SpanTrait};
use option::OptionTrait;

// re-export components from erc_common
use dojo_erc::erc_common::components::{
    operator_approval, OperatorApproval, OperatorApprovalTrait, base_uri, BaseUri, BaseUriTrait
};

//
// ERC721Owner
//

#[derive(Component, Copy, Drop, Serde)]
struct ERC721Owner {
    #[key]
    token: ContractAddress,
    #[key]
    token_id: felt252,
    address: ContractAddress
}


trait ERC721OwnerTrait {
    fn owner_of(
        world: IWorldDispatcher, token: ContractAddress, token_id: felt252
    ) -> ContractAddress;
    fn unchecked_set_owner(
        world: IWorldDispatcher, token: ContractAddress, token_id: felt252, account: ContractAddress
    );
}

impl ERC721OwnerImpl of ERC721OwnerTrait {
    // ERC721: address zero is not a valid owner

    fn owner_of(
        world: IWorldDispatcher, token: ContractAddress, token_id: felt252
    ) -> ContractAddress {
        get!(world, (token, token_id), ERC721Owner).address
    }

    fn unchecked_set_owner(
        world: IWorldDispatcher, token: ContractAddress, token_id: felt252, account: ContractAddress
    ) {
        let mut owner = get!(world, (token, token_id), ERC721Owner);
        owner.address = account;
        set!(world, (owner));
    }
}


//
// ERC721Balance
//

#[derive(Component, Copy, Drop, Serde)]
struct ERC721Balance {
    #[key]
    token: ContractAddress,
    #[key]
    account: ContractAddress,
    amount: u128,
}

trait ERC721BalanceTrait {
    fn balance_of(
        world: IWorldDispatcher, token: ContractAddress, account: ContractAddress
    ) -> u128;
    fn unchecked_transfer_token(
        world: IWorldDispatcher,
        token: ContractAddress,
        from: ContractAddress,
        to: ContractAddress,
        amount: u128,
    );

    fn unchecked_increase_balance(
        world: IWorldDispatcher, token: ContractAddress, owner: ContractAddress, amount: u128,
    );

    fn unchecked_decrease_balance(
        world: IWorldDispatcher, token: ContractAddress, owner: ContractAddress, amount: u128,
    );
}

impl ERC721BalanceImpl of ERC721BalanceTrait {
    fn balance_of(
        world: IWorldDispatcher, token: ContractAddress, account: ContractAddress
    ) -> u128 {
        // ERC721: address zero is not a valid owner
        assert(account.is_non_zero(), 'ERC721: invalid owner address');
        get!(world, (token, account), ERC721Balance).amount
    }

    fn unchecked_transfer_token(
        world: IWorldDispatcher,
        token: ContractAddress,
        from: ContractAddress,
        to: ContractAddress,
        amount: u128,
    ) {
        let mut from_balance = get!(world, (token, from), ERC721Balance);
        from_balance.amount -= amount;
        set!(world, (from_balance));

        let mut to_balance = get!(world, (token, to), ERC721Balance);
        to_balance.amount += amount;
        set!(world, (to_balance));
    }

    fn unchecked_increase_balance(
        world: IWorldDispatcher, token: ContractAddress, owner: ContractAddress, amount: u128,
    ) {
        let mut balance = get!(world, (token, owner), ERC721Balance);
        balance.amount += amount;
        set!(world, (balance));
    }

    fn unchecked_decrease_balance(
        world: IWorldDispatcher, token: ContractAddress, owner: ContractAddress, amount: u128,
    ) {
        let mut balance = get!(world, (token, owner), ERC721Balance);
        balance.amount -= amount;
        set!(world, (balance));
    }
}


//
// ERC721TokenApproval
//

#[derive(Component, Copy, Drop, Serde)]
struct ERC721TokenApproval {
    #[key]
    token: ContractAddress,
    #[key]
    token_id: felt252,
    address: ContractAddress,
}


trait ERC721TokenApprovalTrait {
    fn get_approved(
        world: IWorldDispatcher, token: ContractAddress, token_id: felt252
    ) -> ContractAddress;

    fn unchecked_approve(
        world: IWorldDispatcher, token: ContractAddress, token_id: felt252, to: ContractAddress
    );
}

impl ERC721TokenApprovalImpl of ERC721TokenApprovalTrait {
    fn get_approved(
        world: IWorldDispatcher, token: ContractAddress, token_id: felt252
    ) -> ContractAddress {
        let approval = get!(world, (token, token_id), ERC721TokenApproval);
        approval.address
    }

    fn unchecked_approve(
        world: IWorldDispatcher, token: ContractAddress, token_id: felt252, to: ContractAddress
    ) {
        let mut approval = get!(world, (token, token_id), ERC721TokenApproval);
        approval.address = to;
        set!(world, (approval))
    }
}
