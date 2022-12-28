class ShatterClient {
    constructor(host) {
        this.host = host;
    }
    invokeRPC(operation_name, params) {
        const path = "/" + operation_name;
        const host = this.host;
        function fetchLocation(contentLocation) {
            return new Promise((resolve) => {
                fetch(host + contentLocation).then(r => {
                    let delayHeader = r.headers.get('delay') ?? "";
                    let locationHeader = r.headers.get('location') ?? "";
                    if (Boolean(delayHeader) && Boolean(locationHeader)) {
                        setTimeout(() => {
                            resolve(fetchLocation(locationHeader));
                        }, parseInt(delayHeader));
                    }
                    else {
                        resolve(r.json());
                    }
                }).catch(err => {
                    console.log(err);
                });
            });
        }
        console.log(host + path);
        return fetch(host + path, { method: 'POST', body: JSON.stringify(params) }).then(r => {
            let timeoutHeader = r.headers.get('delay') ?? "";
            let locationHeader = r.headers.get('location') ?? "";
            return new Promise((resolve) => {
                setTimeout(() => {
                    resolve(fetchLocation(locationHeader));
                }, parseInt(timeoutHeader));
            });
        }).catch(err => {
            console.log(err);
        });
    }
}

export { ShatterClient };
