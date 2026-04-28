{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    postgresql
    redis
    sqlite
    libmysqlclient
  ];
}
