# addon-export-csv

Export your domains in CSV format with this simple add-on.



## Setup

1. Clone the repository

```
git clone git@github.com:aetrion/addon-export-csv.git
```

1. Install the dependencies

```
bundle install
```


### Setup the OAuth application

You will need to configure an OAuth application on your DNSimple account so the add-on authentication can function properly.

1. From your account's settings choose *Applications*. Select the *Developer applications* tab and click on *New application*. This is the information you need to input:

    - *Application name*: `CSV Export Add-on`
    - *Homepage URL*: `https://localhost:5000`
    - *Authorization Callback URL*: `http://localhost:5000/callback`

1. Once you have created the application make sure to copy the `Client ID` and the `Client Secret` as you will need them for the next step.


### Setup environment variables

From the add-on project home create a `.env` file. This file is in the `.gitignore` file each one of us can have a different one. You will need the following environment variables there:

```
export DNSIMLE_BASE_URL="https://api.sandbox.dnsimple.com"
export CLIENT_ID="xxxx"
export CLIENT_SECRET="xxxx"
```

#### Setup the host name for your development environment

**WARNING:** _This step is only required if you want to test the add-on against your local development environment of the DNSimple app.  If you are using other environment (like Staging or Sandbox) instead of your development environment this step is not required._

There are certain restrictions about how the DNSimple API works in the development environment. Because of those restrictions you will have to set up custom hosts for the add-on to work:

```
127.0.0.1  dev.dnsimple.com
127.0.0.1  api.dev.dnsimple.com
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
