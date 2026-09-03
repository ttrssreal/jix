{ config, ... }: {
  sops.secrets = {
    cert-firefly-data-importer = {
      owner = "nginx";
      key = "wildcard-app-cert";
    };

    cert-key-firefly-data-importer = {
      owner = "nginx";
      key = "wildcard-app-cert-key";
    };

    firefly-data-importer-pat = {
      owner = config.services.firefly-iii-data-importer.user;
    };

    firefly-data-importer-akahu-app-id-token = {
      owner = config.services.firefly-iii-data-importer.user;
    };

    firefly-data-importer-user-access-token = {
      owner = config.services.firefly-iii-data-importer.user;
    };
  };

  services.firefly-iii-data-importer = {
    enable = true;
    enableNginx = true;
    virtualHost = "firefly-importer.app.jessie.cafe";

    settings = {
      # Firefly Data Importer (FIDI) configuration file

      # Where is Firefly III?
      #
      # 1) Make sure you ADD http:// or https://
      # 2) Make sure you REMOVE any trailing slash from the end of the URL.
      # 3) In case of Docker, refer to the internal IP of your Firefly III installation.
      #
      # Setting this value is not mandatory. But it is very useful.
      #
      # This variable can be set from a file if you append it with _FILE
      #
      FIREFLY_III_URL = "https://firefly.app.jessie.cafe";

      #
      # Imagine Firefly III can be reached at "http://172.16.0.2:8082" (internal Docker network or something).
      # But you have a fancy URL: "https://personal-finances.bill.microsoft.com/"
      #
      # In those cases, you can overrule the URL so when the data importer links back to Firefly III, it uses the correct URL.
      #
      # 1) Make sure you ADD http:// or https://
      # 2) Make sure you REMOVE any trailing slash from the end of the URL.
      #
      # IF YOU SET THIS VALUE, YOU MUST ALSO SET THE FIREFLY_III_URL
      #
      # This variable can be set from a file if you append it with _FILE
      #
      VANITY_URL = "https://firefly.app.jessie.cafe";

      #
      # Set your Firefly III Personal Access Token (OAuth)
      # You can create a Personal Access Token on the /profile/oauth page:
      # go to the "Remote access and tokens" page, then Personal Access Token and "Create new token".
      #
      # - Do not use the "command line token". That's the WRONG one.
      # - Do not use "APP_KEY" value from your Firefly III installation. That's the WRONG one.
      #
      # Setting this value is not mandatory. Instructions will follow if you omit this field.
      #
      # This variable can be set from a file if you append it with _FILE
      #
      FIREFLY_III_ACCESS_TOKEN_FILE = config.sops.secrets.firefly-data-importer-pat.path;

      #
      # Locale information.
      # Set this to your locale. It is used during CSV imports to parse amounts.
      #
      FALLBACK_LOCALE = "en_US";

      #
      # If set to true, the data import will not complain about running into duplicates.
      # This will give you cleaner import mails if you run regular imports.
      #
      # This means that the data importer will not import duplicates, but it will not complain about them either.
      #
      # This setting has no influence on the settings in your configuration(.json).
      #
      # Of course, if something goes wrong *because* the transaction is a duplicate you will
      # NEVER know unless you start digging in your log files. So be careful with this.
      #
      IGNORE_DUPLICATE_ERRORS = "false";

      #
      # If you set this to true, the importer will not complain about transactions that can't be found after they've
      # been imported. This happens when rule on the Firefly III side deletes the transaction immediately after creating it.
      # This can be useful when you have a rule that immediately deletes GoCardless' "pending" transactions. Setting this
      # to true reduces some noise.
      #
      IGNORE_NOT_FOUND_TRANSACTIONS = "false";

      #
      # Is the /autoimport even endpoint enabled?
      # By default it's disabled, and the secret alone will not enable it.
      #
      CAN_POST_AUTOIMPORT = "false";

      #
      # Is the /autoupload endpoint enabled?
      # By default it's disabled, and the secret alone will not enable it.
      #
      CAN_POST_FILES = "false";

      #
      # If you import from a directory, you can save a fallback configuration file in the directory.
      # This file must be called "_fallback.json" and will be used when your CSV or CAMT.053 file is not accompanied
      # by a configuration file.
      #
      # This fallback configuration will only be used if this variable is set to true.
      # https://docs.firefly-iii.org/how-to/data-importer/advanced/post/#importing-a-local-directory
      #
      FALLBACK_IN_DIR = "false";

      #
      # When you're running Firefly III under a (self-signed) certificate,
      # the data importer may have trouble verifying the TLS connection.
      #
      # You have a few options to make sure the data importer can connect
      # to Firefly III:
      # - 'true': will verify all certificates. The most secure option and the default.
      # - 'file.pem': refer to a file (you must provide it) to your custom root or intermediate certificates.
      # - 'false': will verify NO certificates. Not very secure.
      VERIFY_TLS_SECURITY = "true";

      AKAHU_APP_ID_TOKEN_FILE = config.sops.secrets.firefly-data-importer-akahu-app-id-token.path;
      AKAHU_USER_ACCESS_TOKEN_FILE = config.sops.secrets.firefly-data-importer-user-access-token.path;

      #
      # Time out when connecting with Firefly III.
      # π*10 seconds is usually fine.
      #
      CONNECTION_TIMEOUT = "31.41";

      # The following variables can be useful when debugging the application
      APP_ENV = "local";
      APP_DEBUG = false;
      LOG_CHANNEL = "stack";

      #
      # If you turn this on, expect massive logs with lots of privacy sensitive data
      #
      LOG_RETURN_JSON = "false";

      # Log level. You can set this from least severe to most severe:
      # debug, info, notice, warning, error, critical, alert, emergency
      # If you set it to debug your logs will grow large, and fast. If you set it to emergency probably
      # nothing will get logged, ever.
      LOG_LEVEL = "info";

      # TRUSTED_PROXIES is a useful variable when using Docker and/or a reverse proxy.
      # Set it to ** and reverse proxies work just fine.
      TRUSTED_PROXIES = "**";

      #
      # Time zone
      #
      TZ = "Pacific/Auckland";

      #
      # Force Firefly III URL to be secure?
      #
      #
      EXPECT_SECURE_URL = "false";

      #
      # You probably won't need to change these settings.
      #
      BROADCAST_DRIVER = "log";
      CACHE_DRIVER = "file";
      QUEUE_CONNECTION = "sync";
      SESSION_DRIVER = "file";
      SESSION_LIFETIME = "120";
      IS_EXTERNAL = "false";

      APP_NAME = "DataImporter";
    };
  };

  services.nginx.virtualHosts."firefly-importer.app.jessie.cafe" = {
    forceSSL = true;
    sslCertificate = config.sops.secrets.cert-firefly-data-importer.path;
    sslCertificateKey = config.sops.secrets.cert-key-firefly-data-importer.path;
  };
}
