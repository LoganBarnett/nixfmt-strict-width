# Stock nixfmt leaves every binding below past 80 columns.  This file is
# exempt from formatting on purpose.  The README shows the same cases.
{
  description = "Copies every home directory to the offsite store late each night.";
  message = "Host ${host.name} claims ${host.address}, which ${owner.name} already holds on ${network.name}.";
  services.backup = {
    jobs = {
      home = {
        paths = lib.filter (path: path.enabled && path.size != null) allKnownPaths;
      };
    };
  };
  users.users.root.openssh.authorizedKeys.keyFiles = collectAuthorizedKeyFilesFromOtherHosts administratorAccounts currentHostName;
}
