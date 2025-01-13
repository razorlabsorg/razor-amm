import { Account, AccountAddress, Aptos, AptosConfig, Ed25519Account, Ed25519PrivateKey, Network } from "@aptos-labs/ts-sdk";
import dotenv from "dotenv";
import path from "path";
import YAML from "yaml";

const envPath = path.resolve(__dirname, "../../.env");
dotenv.config({ path: envPath });

export interface AptosProviderConfig {
  network: Network;
  addresses: {
    AMM: string;
  };
  rest_url: string;
  faucet_url: string;
}

export interface AccountProfileConfig {
  network: string;
  private_key: string;
  public_key: string;
  account: string;
  rest_url: string;
  faucet_url: string;
}

export enum RAZOR_PROFILES {
  RAZOR_AMM = "razor_amm",
  DEFAULT_FUNDER = "default",
}

export class AptosProvider {
  private network: Network;
  private readonly profileAddressMap: Map<string, AccountAddress> = new Map();
  private readonly profileAccountMap: Map<string, Ed25519PrivateKey> = new Map();
  private aptos: Aptos;

  private constructor() {}

  public static fromConfig(config: AptosProviderConfig): AptosProvider {
    const aptosProvider = new AptosProvider();
    aptosProvider.addProfileAddress(RAZOR_PROFILES.RAZOR_AMM, AccountAddress.fromString(config.addresses.AMM));
    const aptosConfig = new AptosConfig({
      fullnode: config.rest_url,
      faucet: config.faucet_url,
    });

    aptosProvider.setNetwork(config.network);
    aptosProvider.setAptos(aptosConfig);
    return aptosProvider;
  }

  public static fromYaml(yaml: string): AptosProvider {
    const aptosProvider = new AptosProvider();
    const parsedYaml = YAML.parse(yaml);
    for (const profile of Object.keys(parsedYaml.profiles)) {
      const profileConfig = parsedYaml.profiles[profile] as AccountProfileConfig

      switch (profileConfig.network.toLowerCase()) {
        case "custom": {
          const aptosConfig = new AptosConfig({
            fullnode: profileConfig.rest_url,
            faucet: profileConfig.faucet_url,
          });
          aptosProvider.setNetwork(Network.CUSTOM);
          aptosProvider.setAptos(aptosConfig);
          break;
        }
        case "devnet": {
          const aptosConfig = new AptosConfig({
            network: Network.DEVNET,
          });
          aptosProvider.setNetwork(Network.DEVNET);
          aptosProvider.setAptos(aptosConfig);
          break;
        }
        case "mainnet": {
          const aptosConfig = new AptosConfig({
            network: Network.MAINNET,
          });
          aptosProvider.setNetwork(Network.MAINNET);
          aptosProvider.setAptos(aptosConfig);
          break;
        }
        case "local": {
          const aptosConfig = new AptosConfig({
            network: Network.LOCAL,
          });
          aptosProvider.setNetwork(Network.LOCAL);
          aptosProvider.setAptos(aptosConfig);
          break;
        }
        default:
          throw new Error(`Unknown network ${profileConfig.network ? profileConfig.network : "undefined"}`);
      }

      const aptosPrivateKey = new Ed25519PrivateKey(profileConfig.private_key);
      aptosProvider.addProfileAccount(profile, aptosPrivateKey);
      const profileAccount = Account.fromPrivateKey({
        privateKey: aptosPrivateKey,
      });
      aptosProvider.addProfileAddress(profile, profileAccount.accountAddress);
    }

    return aptosProvider;
  }

  public static fromEnvs(): AptosProvider {
    const aptosProvider = new AptosProvider();

    // read vars from .env file
    if (!process.env.APTOS_NETWORK) {
      throw new Error("Missing APTOS_NETWORK in .env file");
    }

    switch (process.env.APTOS_NETWORK.toLowerCase()) {
      case "custom": {
        const aptosConfig = new AptosConfig({
          fullnode: process.env.APTOS_REST_URL,
          faucet: process.env.APTOS_FAUCET_URL,
        });
        aptosProvider.setNetwork(Network.CUSTOM);
        aptosProvider.setAptos(aptosConfig);
        break;
      }
      case "devnet": {
        const aptosConfig = new AptosConfig({
          network: Network.DEVNET,
        });
        aptosProvider.setNetwork(Network.DEVNET);
        aptosProvider.setAptos(aptosConfig);
        break;
      }
      case "mainnet": {
        const aptosConfig = new AptosConfig({
          network: Network.MAINNET,
        });
        aptosProvider.setNetwork(Network.MAINNET);
        aptosProvider.setAptos(aptosConfig);
        break;
      }
      case "local": {
        const aptosConfig = new AptosConfig({
          network: Network.LOCAL,
        });
        aptosProvider.setNetwork(Network.LOCAL);
        aptosProvider.setAptos(aptosConfig);
        break;
      }
      default:
        throw new Error(`Unknown network ${process.env.APTOS_NETWORK ? process.env.APTOS_NETWORK : "undefined"}`);
    }

    if (!process.env.RAZOR_AMM_PRIVATE_KEY) {
      throw new Error("Missing RAZOR_AMM_PRIVATE_KEY in .env file");
    }
    addProfilePrivatekey(aptosProvider, RAZOR_PROFILES.RAZOR_AMM, process.env.RAZOR_AMM_PRIVATE_KEY);

    if (!process.env.DEFAULT_FUNDER_PRIVATE_KEY) {
      throw new Error("Missing DEFAULT_FUNDER_PRIVATE_KEY in .env file");
    }
    addProfilePrivatekey(aptosProvider, RAZOR_PROFILES.DEFAULT_FUNDER, process.env.DEFAULT_FUNDER_PRIVATE_KEY);

    return aptosProvider;
  }

  /** Gets the selected network. */
  public getNetwork(): Network {
    return this.network;
  }

  public setNetwork(network: Network) {
    this.network = network;
  }

  /** Returns the aptos instance. */
  public getAptos(): Aptos {
    return this.aptos;
  }

  /** Returns the profile private key by name if found. */
  public getProfileAccountPrivateKeyByName(profileName: string): Ed25519PrivateKey {
    return this.profileAccountMap.get(profileName);
  }

  /** Returns the profile private key by name if found. */
  public getProfileAccountByName(profileName: string): Ed25519Account {
    return Account.fromPrivateKey({
      privateKey: this.getProfileAccountPrivateKeyByName(profileName),
    });
  }

  /** Returns the profile address by name if found. */
  public getProfileAddressByName(profileName: string): AccountAddress {
    return this.profileAddressMap.get(profileName);
  }

  public addProfileAddress(profileName: string, address: AccountAddress) {
    this.profileAddressMap.set(profileName, address);
  }

  public addProfileAccount(profileName: string, account: Ed25519PrivateKey) {
    this.profileAccountMap.set(profileName, account);
  }

  public setAptos(aptosConfig: AptosConfig) {
    this.aptos = new Aptos(aptosConfig);
  }
}

const addProfilePrivatekey = (aptosProvider: AptosProvider, profile: string, privateKey: string) => {
  const aptosPrivateKey = new Ed25519PrivateKey(privateKey);
  aptosProvider.addProfileAccount(profile, aptosPrivateKey);
  const profileAccount = Account.fromPrivateKey({
    privateKey: aptosPrivateKey,
  });
  aptosProvider.addProfileAddress(profile, profileAccount.accountAddress);
};