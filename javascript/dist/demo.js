import { ShatterClient } from './main.js'

let client = new ShatterClient('http://localhost:9292')
client.invokeRPC('hello_world', {number: 42, name: 'Jerry'}).then(console.log)
