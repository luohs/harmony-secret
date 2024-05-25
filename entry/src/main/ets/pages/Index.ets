import { FileInfo } from '../model/FileInfoModel';
import CommonConstants from '../commons/CommonConstants'
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';
import { BusinessError } from '@ohos.base';
import Logger from '../commons/Logger'
import { common } from '@kit.AbilityKit';


let localStorage = LocalStorage.getShared();

@Entry(localStorage)
@Component
struct Index {
  @State message: string = 'Hello World';
  @LocalStorageProp('fileInfo') fileInfo: FileInfo = new FileInfo(undefined, undefined);
  @LocalStorageProp('isContinuation') isContinuation: string = '';
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear() {
    if ((this.isContinuation === CommonConstants.CAN_CONTINUATION) && this.fileInfo.filename) {
      // 获取分布式文件系统中的附件
    }
  }

  build() {
    Column() {
      Column(){
        Text('显示被接续文字').width('100%').textAlign(TextAlign.Start).margin({ top: 20 })
        TextArea({ placeholder: '显示被接续文字' }).margin({ top: 5 })
          .onSubmit((EnterKeyType)=>{

          })
      }
      Column(){
        Text('显示接续后文字').width('100%').textAlign(TextAlign.Start).margin({ top: 20 })
        TextArea({ placeholder: '显示接续后文字' }).margin({ top: 5 }).enabled(false)/*.type(InputType.Password)*/
          .onSubmit((EnterKeyType)=>{

          })
      }
    }.padding(20)
  }

  // MailHomePage.ets
  documentSelect(fileType: number): void {
    try {
      let DocumentSelectOptions = new picker.DocumentSelectOptions();
      let documentPicker = new picker.DocumentViewPicker();
      // 选取需要传输的附件
      documentPicker.select(DocumentSelectOptions).then((DocumentSelectResult: Array<string>) => {
        for (let documentSelectResultElement of DocumentSelectResult) {
          let buf = new ArrayBuffer(CommonConstants.FILE_BUFFER_SIZE);
          let readSize = 0;
          let file = fs.openSync(documentSelectResultElement, fs.OpenMode.READ_ONLY);
          let readLen = fs.readSync(file.fd, buf, { offset: readSize });
          // File name is not supported chinese name.
          let fileName = file.name;
          // 将附件写入到应用沙箱路径以及分布式文件系统路径
          let destination = fs.openSync(getContext()
            .filesDir + '/' + fileName, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          let destinationDistribute = fs.openSync(getContext()
            .distributedFilesDir + '/' + fileName, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          while (readLen > 0) {
            readSize += readLen;
            fs.writeSync(destination.fd, buf);
            fs.writeSync(destinationDistribute.fd, buf);
            console.info(destinationDistribute.path);
            readLen = fs.readSync(file.fd, buf, { offset: readSize });
          }
          fs.closeSync(file);
          fs.closeSync(destination);
          fs.closeSync(destinationDistribute);
          // 保存附件元信息
          this.fileInfo = new FileInfo(fileName)
        }
        Logger.info(`DocumentViewPicker.select successfully, DocumentSelectResult uri: ${JSON.stringify(DocumentSelectResult)}`);
      }).catch((err: BusinessError) => {
        Logger.error(`DocumentViewPicker.select failed with err: ${JSON.stringify(err)}`);
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(`DocumentViewPicker failed with err: ${JSON.stringify(err)}`);
    }
  }

  readFile(): void {
      // 分布式文件系统的保存路径
      let filePath: string = this.context.distributedFilesDir + '/' + this.fileInfo.filename;
      // 将读取到的文件保存到应用的沙箱路径中
      let savePath: string = this.context.filesDir + '/' + this.fileInfo.filename;

      try {
        while (fs.accessSync(filePath)) {
          let saveFile = fs.openSync(savePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE);
          let buf: ArrayBuffer = new ArrayBuffer(CommonConstants.FILE_BUFFER_SIZE);
          let readSize = 0;
          let readLen = fs.readSync(file.fd, buf, { offset: readSize });
          while (readLen > 0) {
            readSize += readLen;
            fs.writeSync(saveFile.fd, buf);
            readLen = fs.readSync(file.fd, buf, { offset: readSize });
          }
          fs.closeSync(file);
          fs.closeSync(saveFile);
        }
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        Logger.error(`DocumentViewPicker failed with err: ${JSON.stringify(err)}`);
      }
  }
}