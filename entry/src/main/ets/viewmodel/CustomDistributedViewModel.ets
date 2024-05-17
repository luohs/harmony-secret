import { promptAction } from '@kit.ArkUI';
import PermissionManager from '../commons/PermissionsManager'
import CommonConstants from '../commons/CommonConstants';

export default class CustomDistributedViewModel {
  private constructor() {
  }

  private static instance?: CustomDistributedViewModel;

  static getInstance(): CustomDistributedViewModel {
    if (!CustomDistributedViewModel.instance) {
      CustomDistributedViewModel.instance = new CustomDistributedViewModel();
    }

    return CustomDistributedViewModel.instance;
  }

  private permissionModel: PermissionManager = PermissionManager.getInstance();

  async requestDistributedDataSyncPermission(): Promise<boolean> {
    const reqPermissionName = CommonConstants.PERMISSION_DISTRIBUTED_DATASYNC;
    let isGranted = await this.permissionModel.checkPermission(reqPermissionName);
    if (isGranted) {
      return true;
    }
    isGranted = await this.permissionModel.requestPermission(reqPermissionName);
    return isGranted;
  }

  showPermissionDenied(): void {
    promptAction.showToast({
      message: $r('app.string.custom_distributed_dataSync_tips_permissions_denied'),
      duration: 2000
    });
  }
}
