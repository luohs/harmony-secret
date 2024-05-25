export class FileInfo {
  filename?: string = '';
  filepath?: string = '';

  constructor(filename:string|undefined, filepath?:string|undefined) {
    this.filename = filename;
    this.filepath = filepath;
  }
}
