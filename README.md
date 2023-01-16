
![shatter-banner](https://user-images.githubusercontent.com/1334489/211411749-49d3377f-e413-4838-bae7-60705688b514.png#gh-light-mode-only)
![shatter-banner-darkmode](https://user-images.githubusercontent.com/1334489/211412250-0660c441-31f1-4d74-87f8-5118ccebffa0.png#gh-dark-mode-only)

<p align='center'>
An async first RPC app server built in Ruby. Supported by DRb, Puma, and Zookeeper.
</p>


## Whats needed

* Ruby3.1 and later
* A box to run it on
* Zookeeper instance
* Optional: Extra server to run the service layer across different boxes.


## Developing

### Installation
Start with creating your project directory.
```
mkdir MyApp
```

Create a new Gemfile and `bundle install`.
```ruby
source "https://rubygems.org"

gem 'shatter-rb'
```

Create the project with:
```
bundle exec shatter new <AppName>
```
For now, app name should be in provided in UpperCamelCase.


Init zookeeper with the required keys needed
```ruby
bundle exec shatter init_service_discovery
```


Finally, you start shatter by running both the web server and service applications.

```bash
bundle exec shatter server
bundle exec shatter service
```

Congrats! Shatter is up and running!

### Testing things out

Included in the setup is one example `HelloWorldFunction` to show you how things work. You can invoke it with curl like:

```
curl -i -X POST -d '{}' localhost:9292/hello_world
```

Check the `location` header in the response and follow that url till your response is ready. The Javascript client does all this for you, however.


You can check out a demo js script here:
https://github.com/EricRoos/shatter/blob/main/javascript/dist/demo.js



### Front end things

We suggest you use Vite to setup your front end. Shatter comes with the ability to export your functions to a typescript definition that will give you a configured out of the box client ready for use. No need for wiring yourself except for importing whats generated.

You can generate your typescript with:

```
  bundle exec shatter generate_typescript --path web/src/
```

Assuming you have setup your javascript based front end at ./web. This will creaate a `Client` class that is defined with all of your functions. Example of whats generated from the sample app.

```
import { ShatterClient } from 'shatter-client'

interface ShatterResult {
  result: string | number | Array<any> | object,
  error: string | null
  uuid: string
}

class AppClient {
  client: ShatterClient;

  constructor(host: string){
    this.client = new ShatterClient(host)
  }

  async makeRequest<responseType>(operation : string, params : object) : Promise<responseType> {
    return await this.client.invokeRPC(operation,params) as responseType;
  }
}

class Client extends AppClient {
  async helloWorld( params : {name: string, number: number}){
    return this.makeRequest<ShatterResult & {
      result: any
    }>('hello_world', params )
  }
}
export default Client;
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/shatter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/shatter/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Shatter project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/shatter/blob/master/CODE_OF_CONDUCT.md).

## Attribution

Shatter logo provided by: <a href='https://pngtree.com/so/Beautiful'>Beautiful png from pngtree.com/</a>
