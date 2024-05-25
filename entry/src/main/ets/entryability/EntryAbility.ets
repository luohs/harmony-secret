import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import distributedDataObject from '@ohos.data.distributedDataObject';
import {FileInfo} from '../model/FileInfoModel'
import { BusinessError, Device } from '@kit.BasicServicesKit';
import CustomDistributedViewModel from '../viewmodel/CustomDistributedViewModel'
import CommonConstants from '../commons/CommonConstants'

export default class EntryAbility extends UIAbility {

  private fileInfo: FileInfo = new FileInfo('text','distributed');
  private localObject: distributedDataObject.DataObject = distributedDataObject.create(this.context, this.fileInfo);
  private targetDeviceId: string = '';
  private localStorage: LocalStorage = new LocalStorage();

  private customDistributedVM: CustomDistributedViewModel = CustomDistributedViewModel.getInstance();

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    this.restoringData(want, launchParam);
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', this.localStorage, (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    let sessionId: string = distributedDataObject.genSessionId();
    if (this.localObject) {
      this.localObject.setSessionId(sessionId);
      this.localObject['fileInfo'] = this.localStorage.get('fileInfo');
      this.targetDeviceId = wantParam.targetDevice as string;

      this.localObject.save(wantParam.targetDevice as string).then(()=>{
        hilog.info(0x0000, 'testTag', '%{public}s', 'onContinue localObject save success');
      }).catch((err:BusinessError)=>{
        hilog.info(0x0000, 'testTag', '%{public}s', `Failed to save. Code:${err.code},message:${err.message}`);
      })
    }

    return AbilityConstant.OnContinueResult.AGREE;
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.restoringData(want, launchParam);
  }

  async restoringData(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability restoringData');

    const isGranted = await this.customDistributedVM.requestDistributedDataSyncPermission();
    if (!isGranted) {
      this.customDistributedVM.showPermissionDenied();
    }

    // Recovering migrated data from want.
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      if (want.parameters != undefined) {
        this.localStorage.setOrCreate<string>('isContinuation', CommonConstants.CAN_CONTINUATION);
        let sessionId : string = want.parameters?.distributedSessionId as string;
        if (!this.localObject) {
          let fileInfo: FileInfo = new FileInfo(undefined, undefined);
          this.localObject = distributedDataObject.create(this.context, fileInfo);
        }
        if (sessionId && this.localObject) {
          await this.localObject.setSessionId(sessionId);
          this.localStorage.setOrCreate('fileInfo', this.localObject['fileInfo']);
        }
      }
      this.context.restoreWindowStage(this.localStorage);
    }
  }
}
