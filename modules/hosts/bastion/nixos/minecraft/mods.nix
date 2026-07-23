{pkgs}:

{
  FabricAPI = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/5oK85X7C/fabric-api-0.140.0+1.21.11.jar";
    sha512 = "f33d3aa6d4da877975eb0f814f9ac8c02f9641e0192402445912ddab43269efcc685ef14d59fd8ee53deb9b6ff4521442e06e1de1fd1284b426711404db5350b";
  };

  CarpetMod = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/TQTTVgYE/versions/JV4Dlp7j/fabric-carpet-1.21.11-1.4.193+v251211.jar";
    sha512 = "7cc29adfe7de824aad4a32ba2b6d8c899c788a2e5d920e8e63dbddd23ca0702deeedc4948bf562d0326b24402806dc819e6132d26e5513a20495f819d8858dd6";
  };

  # Performance optimization mods 
  FerriteCore = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/uXXizFIs/versions/MGoveONm/ferritecore-8.0.2-fabric.jar";
    sha512 = "3nbxsb8kmv95l3zz9xcxicsc4x7a02wplqfkxwb7gm5rgpd5xw9r80mrxpflhzyfbkp5k44smyvikzy3c6ym0zlyn0zdykd27xr0f4c";
  };

  Syncmatica = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/bfneejKo/versions/fZivQYGD/syncmatica-fabric-1.21.11-0.3.15.jar";
    sha512 = "96e502e902610fed8f7bb2eebfb3f27abedd5f7be7ce0e8b02c936eb0119e35435441fa365a0e0efe0d63c721b1705e739b097bde1f1bf6d59ee45e35a2e4f51";
  };

  LuckPerms = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/Vebnzrzj/versions/CzCJJMuo/LuckPerms-Fabric-5.5.21.jar";
    sha512 = "5dc98d5b3acaab65e8de2873af6b42eced427360f4f50b136b82d2820602341a5fb3cf9f10c27d07e6c7cc556e9d30922492421cb6cc734fa05562e89554fa43";
  };

  iCommon = pkgs.fetchurl {
    url = "https://cdn.modrinth.com/data/SVKv1SZo/versions/rheell3j/iCommon-Fabric-bundle.jar";
    sha512 = "fec1dc103e11e73d27c78283b289466001a08bec211125a1656c914474fbb2afb30784180ea3aa33f92a4a319ecddf04f3113ce1361c0eaf49642d80f40f146c";
  };
}
