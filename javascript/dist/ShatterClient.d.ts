export default class ShatterClient {
    private host;
    constructor(host: string);
    invokeRPC(operation_name: string, params: any): Promise<unknown>;
}
