#[test_only]
module razor_amm::controller_tests {
  use std::signer;
  use aptos_framework::genesis;
  // use aptos_framework::account;

  use razor_amm::controller;
  use razor_amm::factory;
  // use razor_amm::amm_errors;

  const ADMIN: address = @admin;
  const FEE_ADMIN: address = @fee_admin;
  const NEW_ADMIN: address = @0x123;

  public fun setup_test(deployer: &signer) {
    controller::initialize_for_testing(deployer);
    factory::initialize_for_testing(deployer);
  }

  public fun setup_test_with_genesis(deployer: &signer) {
    genesis::setup();
    setup_test(deployer);
  }

  #[test(deployer = @razor_amm)]
  public fun test_can_get_signer(deployer: &signer) {
    controller::initialize_for_test(deployer);
    let signer_address = controller::get_signer_address();
    assert!(signer::address_of(&controller::get_signer()) == signer_address, 0);
  }

  #[test(deployer = @razor_amm)]
  public fun test_initial_config(deployer: &signer) {
    controller::initialize_for_test(deployer);
        
    assert!(controller::get_fee_to() == FEE_ADMIN, 1);
    assert!(controller::get_admin() == ADMIN, 2);
    assert!(controller::get_fee_on() == true, 3);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 1)] // amm_errors::paused()
  public fun test_assert_paused_fails_when_unpaused(deployer: &signer) {
    controller::initialize_for_test(deployer);
    controller::assert_paused();
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 2)] // amm_errors::unpaused()
  public fun test_assert_unpaused_fails_when_paused(deployer: &signer) {
    controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    controller::pause(&admin_signer);
    controller::assert_unpaused();
  }

  #[test(deployer = @razor_amm)]
  public fun test_pause_unpause_as_admin(deployer: &signer) {
    controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
        
    // Test pause
    controller::pause(&admin_signer);
    controller::assert_paused();
        
    // Test unpause
    controller::unpause(&admin_signer);
    controller::assert_unpaused();
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3)] // amm_errors::forbidden()
  public fun test_pause_fails_for_non_admin(deployer: &signer) {
    controller::initialize_for_test(deployer);
    let non_admin = aptos_framework::account::create_signer_for_test(@0x123);
    controller::pause(&non_admin);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3)] // amm_errors::forbidden()
  public fun test_unpause_fails_for_non_admin(deployer: &signer) {
    controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    let non_admin = aptos_framework::account::create_signer_for_test(@0x123);
        
    controller::pause(&admin_signer);
    controller::unpause(&non_admin);
  }

  #[test(deployer = @razor_amm)]
  public fun test_admin_transfer_flow(deployer: &signer) {
    controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    let new_admin_signer = aptos_framework::account::create_signer_for_test(NEW_ADMIN);

    // Set new admin
    controller::set_admin_address(&admin_signer, NEW_ADMIN);
        
    // Claim admin
    controller::claim_admin(&new_admin_signer);
        
    // Verify new admin
    assert!(controller::get_admin() == NEW_ADMIN, 4);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3)] // amm_errors::forbidden()
  public fun test_set_admin_fails_for_non_admin(deployer: &signer) {
    controller::initialize_for_test(deployer);
    let non_admin = aptos_framework::account::create_signer_for_test(@0x123);
    controller::set_admin_address(&non_admin, @0x456);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 5)] // amm_errors::invalid_address()
  public fun test_set_admin_fails_for_zero_address(deployer: &signer) {
    controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    controller::set_admin_address(&admin_signer, @0x0);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 6)] // amm_errors::pending_admin_exists()
  public fun test_set_admin_fails_when_pending_exists(deployer: &signer) {
    controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
        
    controller::set_admin_address(&admin_signer, NEW_ADMIN);
    controller::set_admin_address(&admin_signer, @0x456); // Should fail
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3)] // amm_errors::forbidden()
  public fun test_claim_admin_fails_for_wrong_address(deployer: &signer) {
    controller::initialize_for_test(deployer);
    let admin_signer = aptos_framework::account::create_signer_for_test(ADMIN);
    let wrong_claimer = aptos_framework::account::create_signer_for_test(@0x456);
        
    controller::set_admin_address(&admin_signer, NEW_ADMIN);
    controller::claim_admin(&wrong_claimer);
  }

  #[test(deployer = @razor_amm)]
  #[expected_failure(abort_code = 3)] // amm_errors::no_pending_admin()
  public fun test_claim_admin_fails_when_no_pending(deployer: &signer) {
    controller::initialize_for_test(deployer);
    let new_admin_signer = aptos_framework::account::create_signer_for_test(NEW_ADMIN);
    controller::claim_admin(&new_admin_signer);
  }
}
