#[test_only]
module razor_amm::test_coins {
  use razor_amm::razor_token;
  use razor_amm::usdc_token;
  use razor_amm::usdt_token;
  use razor_amm::wbtc_token;
  use razor_amm::weth_token;

  use aptos_framework::account;

  public entry fun init_coins() {
    let account = &account::create_account_for_test(@razor_amm);
    razor_token::init_for_test(account);
    usdc_token::init_for_test(account);
    usdt_token::init_for_test(account);
    wbtc_token::init_for_test(account);
    weth_token::init_for_test(account);
  }

  public entry fun mint_razor(account: &signer, to: address, amount: u64) {
    razor_token::mint(account, to, amount);
  }

  public entry fun mint_usdc(account: &signer, to: address, amount: u64) {
    usdc_token::mint(account, to, amount);
  }

  public entry fun mint_usdt(account: &signer, to: address, amount: u64) {
    usdt_token::mint(account, to, amount);
  }

  public entry fun mint_wbtc(account: &signer, to: address, amount: u64) {
    wbtc_token::mint(account, to, amount);
  }

  public entry fun mint_weth(account: &signer, to: address, amount: u64) {
    weth_token::mint(account, to, amount);
  }
}