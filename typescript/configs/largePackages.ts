import { MoveFunctionId } from "@aptos-labs/ts-sdk";

export const LargePackagesAccountAddress = "0xa461a44d7a5007a47aa4671f8d897eceac5f98fe67949ca54bc5c556afe04dd7";

// Resource Func Addr
export const StageCodeChunkFuncAddr: MoveFunctionId = `${LargePackagesAccountAddress}::large_packages::stage_code_chunk`;
export const StageCodeChunkAndPublishToAccountFuncAddr: MoveFunctionId = `${LargePackagesAccountAddress}::large_packages::stage_code_chunk_and_publish_to_account`;
export const StageCodeChunkAndPublishToObjectFuncAddr: MoveFunctionId = `${LargePackagesAccountAddress}::large_packages::stage_code_chunk_and_publish_to_object`;
export const StageCodeChunkAndUpgradeObjectCodeFuncAddr: MoveFunctionId = `${LargePackagesAccountAddress}::large_packages::stage_code_chunk_and_upgrade_object_code`;
export const CleanupStagingAreaFuncAddr: MoveFunctionId = `${LargePackagesAccountAddress}::large_packages::cleanup_staging_area`;

