# addon-export-csv

Export your domains in CSV format with this simple addon.



## Setup

1. Clone the repository

```
git clone git@github.com:aetrion/addon-export-csv.git
```

1. Install the dependencies

```
bundle install
```


### Integrating with the DNSimple app in development

#### Setup the host name

There are certain restrictions about how the DNSimple API works in the development environment. Because of those restrictions you will have to set up custom hosts for the addon to work:

```
127.0.0.1  dev.dnsimple.com
127.0.0.1  api.dev.dnsimple.com
```


#### Setup the OAuth application

You will need to configure an OAuth application on your DNSimple development environment so the addon authentication can function properly.

The first thing you should do is enable the OAuth feature for your user.

Then from your account's settings choose *Applications*. Select the *Developer applications* tab and click on *New application*. This is the information you need to input:

- *Application name*: `CSV Export addon`
- *Homepage URL*: `http://localhost:5000`
- *Authorization Callback URL*: `http://localhost:5000/callback`

Once you have created the application make sure to copy the `Client ID` and the `Client Secret` as you will need them for the next step.


#### Setup environment variables

From the addon project home create a `.env` file. This file is in the `.gitignore` file each one of us can have a different one. You will need the following environment variables there:

```
export API_ENDPOINT="dev.dnsimple.com"
export API_PORT="3000"
export CLIENT_ID="xxxx"
export CLIENT_SECRET="xxxx"
```



## Running the server

The project has a `Procfile` for Heroku to run it. You can also use Foreman to run the server:

```
foreman start
```



## Running the tests

```
bundle exec rake
```

or

```
bundle exec rspec
```
