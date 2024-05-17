import CustomDistributedViewModel from '../viewmodel/CustomDistributedViewModel'

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  // 自定义扫码vm实例
  private customDistributedVM: CustomDistributedViewModel = CustomDistributedViewModel.getInstance();
  // 授权标志
  @State isGranted: boolean = false;

  async aboutToAppear() {
    const isGranted = await this.customDistributedVM.requestDistributedDataSyncPermission();
    if (!isGranted) {
      this.customDistributedVM.showPermissionDenied();
    }
    this.isGranted = isGranted;
  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}