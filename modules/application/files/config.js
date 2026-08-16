// define default config, but allow overrides from ENV vars
let config = {
  APP_DB_HOST: "",
  APP_DB_USER: "",
  APP_DB_PASSWORD: "",
  APP_DB_NAME: ""
}

var AWS = require('aws-sdk');
var client = new AWS.SecretsManager();

const secretName = "Mydbsecret";

client.getSecretValue({SecretId: secretName}, function(err, data) {
    if (err) {
      config.APP_DB_HOST = "localhost"
      config.APP_DB_NAME = "STUDENTS"
      config.APP_DB_PASSWORD = "student12"
      config.APP_DB_USER = "nodeapp"
      console.log('Secrets not found. Proceeding with default values..')
    }
    else {
        if ('SecretString' in data) {
            secret = JSON.parse(data.SecretString);
            for(const envKey of Object.keys(secret)) {
                process.env[envKey] = secret[envKey];

                if (envKey == 'user') {
                  config.APP_DB_USER = secret[envKey]
                } else if (envKey == 'password') {
                  config.APP_DB_PASSWORD = secret[envKey]
                } else if (envKey == 'host') {
                  config.APP_DB_HOST = secret[envKey]
                } else if (envKey == 'db') {
                  config.APP_DB_NAME = secret[envKey]
                }
            }
        }
    }
});

Object.keys(config).forEach(key => {
  if(process.env[key] === undefined){
    console.log(`[NOTICE] Value for key '${key}' not found in ENV, using default value.  See app/config/config.js`)
  } else {
    config[key] = process.env[key]
  }
});

module.exports = config;
