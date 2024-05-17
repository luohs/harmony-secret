import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger'

export default class PermissionManager {
  private constructor() {
  }

  private static instance?: PermissionManager;

  static getInstance(): PermissionManager {
    if (!PermissionManager.instance) {
      PermissionManager.instance = new PermissionManager();
    }

    return PermissionManager.instance;
  }

  /**
   * 检测是否已授权
   * @param {Permissions} permissionName 检测授权的权限名
   * @returns {boolean} 检测结果
   */
  async checkPermission(permissionName: Permissions): Promise<boolean> {
    const grantStatus: abilityAccessCtrl.GrantStatus = await this.requestGrantStatus(permissionName);
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      return true;
    }

    return false;
  }

  /**
   * 检测权限状态
   * @param {Permissions} permission 检测授权的权限名
   * @returns {Promise<abilityAccessCtrl.GrantStatus>} 权限状态
   */
  async requestGrantStatus(permission: Permissions): Promise<abilityAccessCtrl.GrantStatus> {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let grantStatus: abilityAccessCtrl.GrantStatus = abilityAccessCtrl.GrantStatus.PERMISSION_DENIED;

    let tokenId: number = 0;
    try {
      const bundleInfo: bundleManager.BundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      const appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to get bundle info for self. Code is ${err.code}, message is ${err.message}`);
    }

    try {
      grantStatus = await atManager.checkAccessToken(tokenId, permission);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to check access token. Code is ${err.code}, message is ${err.message}`);
    }

    return grantStatus;
  }

  /**
   * 向用户申请授权
   * @param {Permissions} permissionName 申请授权的权限名
   * @returns {boolean} 申请授权结果
   */
  async requestPermission(permissionName: Permissions) {
    let context = getContext() as common.UIAbilityContext;
    let atManager = abilityAccessCtrl.createAtManager();
    let grantStatusArr = await atManager.requestPermissionsFromUser(context, [ permissionName ]);
    const grantStatus = grantStatusArr.authResults[0];
    if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
      return true;
    }

    return false;
  }
}
