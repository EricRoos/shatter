export default class ShatterClient {
  private host : string;
  constructor(host: string){
    this.host = host;
  }

  invokeRPC(operation_name:string, params:any){
    const path = "/"+operation_name;
    const host = this.host;
    function fetchLocation(contentLocation:string){
      return new Promise((resolve) => {
        fetch(host+contentLocation).then( r => {
          let delayHeader : string  = r.headers.get('delay') ?? "";
          let locationHeader: string = r.headers.get('location') ?? "";
          if(Boolean(delayHeader) && Boolean(locationHeader)){
            let timeout = parseInt(delayHeader);
            setTimeout( () => {
              resolve(fetchLocation(locationHeader))
            }, parseInt(delayHeader))
          }else{
            resolve(r.json());
          }
        }).catch(err => {
          console.log(err);
        });
      });
    }
    console.log(host+path)
    return fetch(host+path, {method: 'POST', body: JSON.stringify(params)}).then( r => {
      let timeoutHeader : string  = r.headers.get('delay') ?? "";
      let locationHeader: string = r.headers.get('location') ?? "";
      let timeout = parseInt(timeoutHeader);
      return new Promise((resolve) => {
        setTimeout( () => {
          resolve(fetchLocation(locationHeader));
        }, parseInt(timeoutHeader))
      });
    }).catch(err => {
      console.log(err);
    })
  }
}
