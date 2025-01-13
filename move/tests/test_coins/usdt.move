#[test_only]
module razor_amm::usdt_token {
    use aptos_framework::dispatchable_fungible_asset;
    use aptos_framework::event;
    use aptos_framework::function_info;
    use aptos_framework::fungible_asset::{Self, MintRef, TransferRef, BurnRef, Metadata, FungibleAsset, FungibleStore};
    use aptos_framework::object::{Self, Object, ExtendRef};
    use aptos_framework::primary_fungible_store;

    use std::option;
    use std::signer;
    use std::string::{Self, utf8, String};

    /// Caller is not authorized to make this call
    const ERROR_UNAUTHORIZED: u64 = 11;
    /// No operations are allowed when contract is paused
    const ERROR_PAUSED: u64 = 12;

    /// Contract is needs to be paused first
    const ERROR_UNPAUSED: u64 = 13;

    /// The account is not owner
    const ERROR_NOT_OWNER: u64 = 14;

    /// The account is denylisted
    const ERROR_DENYLISTED: u64 = 15;

    const ASSET_SYMBOL: vector<u8> = b"USDT";
    const ASSET_NAME: vector<u8> = b"Tether USD";
    const DECIMALS: u8 = 8;

    const MAX_SUPPLY: u128 = 100000000000000000;

    // TODO Add Supply cap

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Ownership has key {
        owner: address
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Management has key {
        extend_ref: ExtendRef,
        mint_ref: MintRef,
        burn_ref: BurnRef,
        transfer_ref: TransferRef,
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct State has key {
        paused: bool,
    }

    #[event]
    struct MintEvent has drop, store {
        minter: address,
        to: address,
        amount: u64,
    }

    #[event]
    struct BurnEvent has drop, store {
        minter: address,
        from: address,
        store: Object<FungibleStore>,
        amount: u64,
    }

    #[event]
    struct PauseEvent has drop, store {
        admin: address,
        is_paused: bool,
    }

    #[event]
    struct DenylistEvent has drop, store {
        admin: address,
        account: address,
    }

    #[view]
    public fun name(): String {
        return utf8(ASSET_NAME)
    }

    #[view]
    public fun symbol(): String {
        return utf8(ASSET_SYMBOL)
    }

    #[view]
    public fun decimals(): u8 {
        return DECIMALS
    }

    #[view]
    fun owner(): address acquires Ownership {
        let owner = borrow_global<Ownership>(usdt_token_address()).owner;
        return owner
    }

    #[view]
    public fun usdt_token_address(): address {
        object::create_object_address(&@razor_amm, ASSET_SYMBOL)
    }

    #[view]
    public fun metadata(): Object<Metadata> {
        object::address_to_object(usdt_token_address())
    }

    #[view]
    public fun total_supply(): u128 {
        let supply_option = fungible_asset::supply(metadata());
        return option::get_with_default(&supply_option, 0)
    }

    #[view]
    public fun max_supply(): u128 {
        let supply_option = fungible_asset::maximum(metadata());
        return option::get_with_default(&supply_option, 0)
    }

    #[view]
    public fun balance_of(account: address): u64 {
        let balance = primary_fungible_store::balance(account, metadata());
        return balance
    }

    fun init_module(admin: &signer) {
        let constructor_ref = &object::create_named_object(admin, ASSET_SYMBOL);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::some(MAX_SUPPLY),
            utf8(ASSET_NAME),
            utf8(ASSET_SYMBOL),
            DECIMALS,
            utf8(b"https://ipfs.io/ipfs/QmUofuPhv74Swgkt5JCoZKM6Aipnp5iEnddHfzis5CRnxM"),
            utf8(b"https://razordex.xyz"),
        );

        fungible_asset::set_untransferable(constructor_ref);

        let metadata_object_signer = &object::generate_signer(constructor_ref);
        move_to(metadata_object_signer, Ownership {
            owner: @admin,
        });

        move_to(metadata_object_signer, Management {
            extend_ref: object::generate_extend_ref(constructor_ref),
            mint_ref: fungible_asset::generate_mint_ref(constructor_ref),
            burn_ref: fungible_asset::generate_burn_ref(constructor_ref),
            transfer_ref: fungible_asset::generate_transfer_ref(constructor_ref),
        });

        move_to(metadata_object_signer, State {
            paused: false,
        });

        
        let deposit = function_info::new_function_info(
            admin,
            string::utf8(b"usdt_token"),
            string::utf8(b"deposit"),
        );
        let withdraw = function_info::new_function_info(
            admin,
            string::utf8(b"usdt_token"),
            string::utf8(b"withdraw"),
        );
        dispatchable_fungible_asset::register_dispatch_functions(
            constructor_ref,
            option::some(withdraw),
            option::some(deposit),
            option::none(),
        );
    }

    public fun deposit<T: key>(
        store: Object<T>,
        fa: FungibleAsset,
        transfer_ref: &TransferRef,
    ) acquires State {
        assert_not_paused();
        assert_not_denylisted(object::owner(store));
        fungible_asset::deposit_with_ref(transfer_ref, store, fa);
    }

    public fun withdraw<T: key>(
        store: Object<T>,
        amount: u64,
        transfer_ref: &TransferRef,
    ): FungibleAsset acquires State {
        assert_not_paused();
        assert_not_denylisted(object::owner(store));
        fungible_asset::withdraw_with_ref(transfer_ref, store, amount)
    }

    public entry fun mint(minter: &signer, to: address, amount: u64) acquires Management, Ownership, State {
        assert_not_paused();
        is_owner(minter);
        assert_not_denylisted(to);
        if (amount == 0) { return };

        let management = borrow_global<Management>(usdt_token_address());
        let tokens = fungible_asset::mint(&management.mint_ref, amount);
        deposit(primary_fungible_store::ensure_primary_store_exists(to, metadata()), tokens, &management.transfer_ref);

        event::emit(MintEvent {
            minter: signer::address_of(minter),
            to,
            amount,
        });
    }

    public entry fun burn(minter: &signer, from: address, amount: u64) acquires Management, Ownership, State {
        burn_from(minter, primary_fungible_store::ensure_primary_store_exists(from, metadata()), amount);
    }

    public entry fun burn_from(
        minter: &signer,
        store: Object<FungibleStore>,
        amount: u64,
    ) acquires Management, Ownership, State {
        assert_not_paused();
        is_owner(minter);
        if (amount == 0) { return };

        let management = borrow_global<Management>(usdt_token_address());
        let tokens = fungible_asset::withdraw_with_ref(
            &management.transfer_ref,
            store,
            amount,
        );
        fungible_asset::burn(&management.burn_ref, tokens);

        event::emit(BurnEvent {
            minter: signer::address_of(minter),
            from: object::owner(store),
            store,
            amount,
        });
    }

    public entry fun set_pause(admin: &signer, paused: bool) acquires Ownership, State {
        let ownership = borrow_global<Ownership>(usdt_token_address());
        assert!(signer::address_of(admin) == ownership.owner, ERROR_UNAUTHORIZED);
        let state = borrow_global_mut<State>(usdt_token_address());
        if (state.paused == paused) { return };
        state.paused = paused;

        event::emit(PauseEvent {
            admin: signer::address_of(admin),
            is_paused: paused,
        });
    }

    public entry fun denylist(admin: &signer, account: address) acquires Management, Ownership, State {
        assert_not_paused();
        let ownership = borrow_global<Ownership>(usdt_token_address());
        assert!(signer::address_of(admin) == ownership.owner, ERROR_UNAUTHORIZED);

        let freeze_ref = &borrow_global<Management>(usdt_token_address()).transfer_ref;
        primary_fungible_store::set_frozen_flag(freeze_ref, account, true);

        event::emit(DenylistEvent {
            admin: signer::address_of(admin),
            account,
        });
    }

    public entry fun undenylist(admin: &signer, account: address) acquires Management, Ownership, State {
        assert_not_paused();
        let ownership = borrow_global<Ownership>(usdt_token_address());
        assert!(signer::address_of(admin) == ownership.owner, ERROR_UNAUTHORIZED);

        let freeze_ref = &borrow_global<Management>(usdt_token_address()).transfer_ref;
        primary_fungible_store::set_frozen_flag(freeze_ref, account, false);

        event::emit(DenylistEvent {
            admin: signer::address_of(admin),
            account,
        });
    }

    public entry fun transfer_ownership(admin: &signer, new_owner: address) acquires Ownership, State {
        assert_not_paused();
        let ownership = borrow_global_mut<Ownership>(usdt_token_address());
        assert!(signer::address_of(admin) == ownership.owner, ERROR_UNAUTHORIZED);
        ownership.owner = new_owner;
    }

    fun is_owner(minter: &signer) acquires Ownership {
        let ownership = borrow_global<Ownership>(usdt_token_address());
        let minter_addr = signer::address_of(minter);
        assert!(minter_addr == ownership.owner, ERROR_NOT_OWNER);
    }

    fun assert_not_paused() acquires State {
        let state = borrow_global<State>(usdt_token_address());
        assert!(!state.paused, ERROR_PAUSED);
    }

    fun assert_not_denylisted(account: address) {
        let metadata = metadata();
        if (primary_fungible_store::primary_store_exists_inlined(account, metadata)) {
            assert!(!fungible_asset::is_frozen(primary_fungible_store::primary_store_inlined(account, metadata)), ERROR_DENYLISTED);
        }
    }

    #[test_only]
    public fun init_for_test(admin: &signer) {
        init_module(admin);
    }
}
