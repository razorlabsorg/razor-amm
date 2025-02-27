#[test_only]
module razor_amm::amm_controller_tests {
  use std::signer;
  use aptos_framework::genesis;

  use razor_amm::amm_controller;
  use razor_amm::amm_factory;

  const ADMIN: address = @admin;
  const FEE_ADMIN: address = @fee_admin;
  const NEW_ADMIN: address = @0x123;

  public fun setup_test(deployer: &signer) {
    amm_controller::initialize_for_testing(deployer);
    amm_factory::initialize_for_testing(deployer);
  }

  public fun setup_test_with_genesis(deployer: &signer) {
    genesis::setup();
    setup_test(deployer);
  }

  #[test(deployer = @razor_amm)]
  public fun test_can_get_signer(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let signer_address = amm_controller::get_signer_address();
    assert!(signer::address_of(&amm_controller::get_signer()) == signer_address, 0);
  }

  #[test(deployer = @razor_amm)]
  public fun test_initial_config(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
        
    assert!(amm_controller::get_fee_to() == FEE_ADMIN, 1);
    assert!(amm_controller::get_admin() == ADMIN, 2);
    assert!(amm_controller::get_fee_on() == true, 3);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 2, location = razor_amm::amm_controller)] // amm_errors::paused()
  public fun test_assert_paused_fails_when_unpaused(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    amm_controller::assert_paused();
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 1, location = razor_amm::amm_controller)] // amm_errors::unpaused()
  public fun test_assert_unpaused_fails_when_paused(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    amm_controller::pause(&admin_signer);
    amm_controller::assert_unpaused();
  }

  #[test(deployer = @razor_amm)]
  public fun test_pause_unpause_as_admin(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
        
    // Test pause
    amm_controller::pause(&admin_signer);
    amm_controller::assert_paused();
        
    // Test unpause
    amm_controller::unpause(&admin_signer);
    amm_controller::assert_unpaused();
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3, location = razor_amm::amm_controller)] // amm_errors::forbidden()
  public fun test_pause_fails_for_non_admin(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let non_admin = aptos_framework::account::create_signer_for_test(@0x123);
    amm_controller::pause(&non_admin);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3, location = razor_amm::amm_controller)] // amm_errors::forbidden()
  public fun test_unpause_fails_for_non_admin(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    let non_admin = aptos_framework::account::create_signer_for_test(@0x123);
        
    amm_controller::pause(&admin_signer);
    amm_controller::unpause(&non_admin);
  }

  #[test(deployer = @razor_amm)]
  public fun test_admin_transfer_flow(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    let new_admin_signer = aptos_framework::account::create_signer_for_test(NEW_ADMIN);

    // Set new admin
    amm_controller::set_admin_address(&admin_signer, NEW_ADMIN);
        
    // Claim admin
    amm_controller::claim_admin(&new_admin_signer);
        
    // Verify new admin
    assert!(amm_controller::get_admin() == NEW_ADMIN, 4);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3, location = razor_amm::amm_controller)] // amm_errors::forbidden()
  public fun test_set_admin_fails_for_non_admin(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let non_admin = aptos_framework::account::create_signer_for_test(@0x123);
    amm_controller::set_admin_address(&non_admin, @0x456);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 5, location = razor_amm::amm_controller)] // amm_errors::invalid_address()
  public fun test_set_admin_fails_for_zero_address(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    amm_controller::set_admin_address(&admin_signer, @0x0);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 6, location = razor_amm::amm_controller)] // amm_errors::pending_admin_exists()
  public fun test_set_admin_fails_when_pending_exists(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
        
    amm_controller::set_admin_address(&admin_signer, NEW_ADMIN);
    amm_controller::set_admin_address(&admin_signer, @0x456); // Should fail
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3, location = razor_amm::amm_controller)] // amm_errors::forbidden()
  public fun test_claim_admin_fails_for_wrong_address(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    let wrong_claimer = aptos_framework::account::create_signer_for_test(@0x456);
        
    amm_controller::set_admin_address(&admin_signer, NEW_ADMIN);
    amm_controller::claim_admin(&wrong_claimer);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3, location = razor_amm::amm_controller)] // amm_errors::no_pending_admin()
  public fun test_claim_admin_fails_when_no_pending(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let new_admin_signer = aptos_framework::account::create_signer_for_test(NEW_ADMIN);
    amm_controller::claim_admin(&new_admin_signer);
  }

  #[test(deployer = @razor_amm)]
  public fun test_set_fee_to(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    let new_fee_to = @0x789;

    // Set new fee_to address
    amm_controller::set_fee_to(&admin_signer, new_fee_to);
        
    // Verify new fee_to
    assert!(amm_controller::get_fee_to() == new_fee_to, 1);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3, location = razor_amm::amm_controller)] // amm_errors::forbidden()
  public fun test_set_fee_to_fails_for_non_admin(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let non_admin = aptos_framework::account::create_signer_for_test(@0x123);
    amm_controller::set_fee_to(&non_admin, @0x456);
  }

  #[test(deployer = @razor_amm)]
  public fun test_set_fee_to_can_be_zero_address(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
        
    // Set fee_to to zero address
    amm_controller::set_fee_to(&admin_signer, @0x0);
        
    // Verify fee_to is zero address
    assert!(amm_controller::get_fee_to() == @0x0, 1);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3, location = razor_amm::amm_controller)] // amm_errors::no_pending_admin()
  public fun test_claim_admin_fails_with_zero_pending(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
        
    // Try to claim admin when pending_admin is zero address
    amm_controller::claim_admin(&admin_signer);
  }

  #[test(deployer = @razor_amm)]
  public fun test_get_signer_address_matches_razor_amm(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let object_signer = @0xe46a3c36283330c97668b5d4693766b8626420a5701c18eb64026075c3ec8a0a;
    assert!(amm_controller::get_signer_address() == object_signer, 1);
  }

  #[test(deployer = @razor_amm)]
  public fun test_fee_on_default_is_true(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    assert!(amm_controller::get_fee_on() == true, 1);
  }

  #[test(deployer = @razor_amm)]
  public fun test_safe_swap_config_exists_after_init(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    // Just calling get_fee_to() is enough to verify the config exists and can be accessed
    let _ = amm_controller::get_fee_to();
  }

  #[test(deployer = @razor_amm)]
  public fun test_initialize_idempotent(deployer: &signer) {
    // First initialization
    amm_controller::initialize_for_test(deployer);
    let fee_to_1 = amm_controller::get_fee_to();
    
    // Second initialization should not change state
    amm_controller::initialize_for_test(deployer);
    let fee_to_2 = amm_controller::get_fee_to();
    
    assert!(fee_to_1 == fee_to_2, 1);
  }

  #[test(deployer = @razor_amm)]
  public fun test_pause_state_transitions(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    
    // Initially unpaused
    amm_controller::assert_unpaused();
    
    // After pause
    amm_controller::pause(&admin_signer);
    amm_controller::assert_paused();
    
    // After unpause
    amm_controller::unpause(&admin_signer);
    amm_controller::assert_unpaused();
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 1, location = razor_amm::amm_controller)] // amm_errors::paused()
  public fun test_pause_when_already_paused(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    
    // First pause
    amm_controller::pause(&admin_signer);
    // Second pause should fail
    amm_controller::pause(&admin_signer);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 2, location = razor_amm::amm_controller)] // amm_errors::unpaused()
  public fun test_unpause_when_already_unpaused(deployer: &signer) {
    amm_controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    
    // Try to unpause when already unpaused
    amm_controller::unpause(&admin_signer);
  }
}
