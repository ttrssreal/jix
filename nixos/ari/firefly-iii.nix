{ config, ... }: {
  sops.secrets = {
    cert-firefly = {
      owner = "nginx";
      key = "wildcard-app-cert";
    };

    cert-key-firefly = {
      owner = "nginx";
      key = "wildcard-app-cert-key";
    };

    firefly-app-key = {
      owner = config.services.firefly-iii.user;
    };

    firefly-static-cron-token = {
      owner = config.services.firefly-iii.user;
    };
  };

  services.firefly-iii = {
    enable = true;
    enableNginx = true;
    virtualHost = "firefly.app.jessie.cafe";

    settings = {
      # Set to true if you want to see debug information in error screens.
      APP_DEBUG = "false";

      # This should be your email address.
      # If you use Docker or similar, you can set this variable from a file by using SITE_OWNER_FILE
      # The variable is used in some errors shown to users who aren't admin.
      SITE_OWNER = "jess@jessie.cafe";

      # The encryption key for your sessions. Keep this very secure.
      # Change it to a string of exactly 32 chars or use something like `php artisan key:generate` to generate it.
      # If you use Docker or similar, you can set this variable from a file by using APP_KEY_FILE
      #
      # Try to avoid special characters like #, < and > in your app key. This string does not need full entropy
      # When in doubt, follow the link below and pick one.
      #
      # https://www.random.org/strings/?num=5&len=32&digits=on&upperalpha=on&loweralpha=on&unique=on&format=html&rnd=new
      #
      # If you are a fancy linux nerd like me, use this command:
      #
      # head /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9' | head -c 32 && echo
      #
      #
      APP_KEY_FILE = config.sops.secrets.firefly-app-key.path;

      # Firefly III will launch using this language (for new users and unauthenticated visitors)
      # For a list of available languages: https://github.com/firefly-iii/firefly-iii/blob/main/config/firefly.php#L123
      #
      # If text is still in English, remember that not everything may have been translated.
      DEFAULT_LANGUAGE = "en_US";

      # The locale defines how numbers are formatted.
      # by default this value is the same as whatever the language is.
      DEFAULT_LOCALE = "equal";

      # Change this value to your preferred time zone.
      # Example: Europe/Amsterdam
      # For a list of supported time zones, see https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
      TZ = "Pacific/Auckland";

      # TRUSTED_PROXIES is a useful variable when using Docker and/or a reverse proxy.
      # Set it to ** and reverse proxies work just fine.
      TRUSTED_PROXIES = "**";

      # The log channel defines where your log entries go to.
      # Several other options exist. You can use 'single' for one big fat error log (not recommended).
      # Also available are 'syslog', 'errorlog' and 'stdout' which will log to the system itself.
      # A rotating log option is 'daily', creates 5 files that (surprise) rotate.
      # A cool option is 'papertrail' for cloud logging
      # Default setting 'stack' will log to 'daily' and to 'stdout' at the same time.
      LOG_CHANNEL = "stack";

      # Log level. You can set this from least severe to most severe:
      # debug, info, notice, warning, error, critical, alert, emergency
      # If you set it to debug your logs will grow large, and fast. If you set it to emergency probably
      # nothing will get logged, ever.
      APP_LOG_LEVEL = "notice";

      # Audit log level.
      # The audit log is used to log notable Firefly III events on a separate channel.
      # These log entries may contain sensitive financial information.
      # The audit log is disabled by default.
      #
      # To enable it, set AUDIT_LOG_LEVEL to "info"
      # To disable it, set AUDIT_LOG_LEVEL to "emergency"
      AUDIT_LOG_LEVEL = "emergency";

      #
      # If you want, you can redirect the audit logs to another channel.
      # Set 'audit_stdout', 'audit_syslog', 'audit_errorlog' to log to the system itself.
      # Use audit_daily to log to a rotating file.
      # Use audit_papertrail to log to papertrail.
      #
      # If you do this, the audit logs may be mixed with normal logs because the settings for these channels
      # are often the same as the settings for the normal logs.
      AUDIT_LOG_CHANNEL = "";

      # If you're looking for performance improvements, you could install memcached or redis
      CACHE_DRIVER = "file";
      SESSION_DRIVER = "file";

      # Cookie settings. Should not be necessary to change these.
      # If you use Docker or similar, you can set COOKIE_DOMAIN_FILE to set
      # the value from a file instead of from an environment variable
      # Setting samesite to "strict" may give you trouble logging in.
      COOKIE_PATH = "/";
      COOKIE_DOMAIN = "";
      COOKIE_SECURE = "false";
      COOKIE_SAMESITE = "lax";

      # The map will default to this location:
      MAP_DEFAULT_LAT = "51.983333";
      MAP_DEFAULT_LONG = "5.916667";
      MAP_DEFAULT_ZOOM = "6";

      #
      # Firefly III authentication settings
      #

      #
      # Firefly III supports a few authentication methods:
      # - 'web' (default, uses built in DB)
      # - 'remote_user_guard' for Authelia etc
      # Read more about these settings in the documentation.
      # https://docs.firefly-iii.org/how-to/firefly-iii/advanced/authentication/
      #
      # LDAP is no longer supported :(
      #
      AUTHENTICATION_GUARD = "web";

      #
      # Remote user guard settings
      #
      AUTHENTICATION_GUARD_HEADER = "REMOTE_USER";
      AUTHENTICATION_GUARD_EMAIL = "";

      # You can disable the X-Frame-Options header if it interferes with tools like
      # Organizr. This is at your own risk. Applications running in frames run the risk
      # of leaking information to their parent frame.
      DISABLE_FRAME_HEADER = "false";

      # You can disable the Content Security Policy header when you're using an ancient browser
      # or any version of Microsoft Edge / Internet Explorer (which amounts to the same thing really)
      # This leaves you with the risk of not being able to stop XSS bugs should they ever surface.
      # This is at your own risk.
      DISABLE_CSP_HEADER = "false";

      #
      # The static cron job token can be useful when you use Docker and wish to manage cron jobs.
      # 1. Set this token to any 32-character value (this is important!).
      # 2. Use this token in the cron URL instead of a user's command line token that you can find in /profile
      #
      # For more info: https://docs.firefly-iii.org/how-to/firefly-iii/advanced/cron/
      #
      # You can set this variable from a file by appending it with _FILE
      #
      STATIC_CRON_TOKEN_FILE = config.sops.secrets.firefly-static-cron-token.path;

      # You can fine tune the start-up of a Docker container by editing these environment variables.
      # Use this at your own risk. Disabling certain checks and features may result in lots of inconsistent data.
      # However if you know what you're doing you can significantly speed up container start times.
      # Set each value to true to enable, or false to disable.

      # Check if the SQLite database exists. Can be skipped if you're not using SQLite.
      # Won't significantly speed up things.
      DKR_CHECK_SQLITE = "true";

      # Leave the following configuration vars as is.
      # Unless you like to tinker and know what you're doing.
      APP_NAME = "FireflyIII";
      BROADCAST_DRIVER = "log";
      QUEUE_DRIVER = "sync";
      CACHE_PREFIX = "firefly";

      #
      # The v2 layout is very experimental. If it breaks you get to keep both parts.
      # Be wary of data loss.
      #
      FIREFLY_III_LAYOUT = "v1";
    };
  };

  services.nginx.virtualHosts."firefly.app.jessie.cafe" = {
    forceSSL = true;
    sslCertificate = config.sops.secrets.cert-firefly.path;
    sslCertificateKey = config.sops.secrets.cert-key-firefly.path;
  };
}
