<p align="center">
  scoop-apps
</p>
<p align="center">
  <a href="https://github.com/kkzzhizhou/scoop-apps"><img alt="GitHub" src="https://img.shields.io/badge/Readme--Style-standard--repository-brightgreen?style=flat-square&color=f83500"/></a>
  <a href="https://github.com/kkzzhizhou/scoop-apps"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/kkzzhizhou/scoop-apps?style=flat-square"/></a>
  <a href="https://github.com/kkzzhizhou"><img alt="GitHub user" src="https://img.shields.io/badge/author-kkzzhizhou-brightgreen?style=flat-square"/></a>
</p>


## 介绍

此仓库每天自动合并其他scoop仓库的更新

注意：如果仓库描述文件过时或者安装等问题，请根据仓库根路径的app-contributor-list.csv到相应的仓库提交issues

## 特性

- 每天更新
- 仓库列表根据项目[scoop-directory](https://github.com/rasa/scoop-directory)动态生成
- 自动处理同名文件，并优先采用较新版本, 重名文件以"软件-贡献人ID"重命名
- 自动去重（基于md5)
- json格式检验
- 支持仓库推荐、不推荐列表

## 说明

- 可接受仓库推荐，提交pr至bucket-recommend.txt即可
- 可接受"不维护仓库清理”，需在pr中说明理由，提交pr至bucket-not-recommend.txt即可
- **未对仓库软件来源进行安全检验，请自行甄别恶意软件，或者使用杀毒软件**
- 如果有软件安装问题，请参考仓库根路径的app-contributor-list.csv到相应的仓库提交issues

## 使用方法

```
scoop bucket add apps https://github.com/kkzzhizhou/scoop-apps
```

### 安装部分软件Hash Check Failed



因描述文件更新有概率更新到错误的文件，所以安装时出现“Hash Check Failed”，可以使用`-s`忽略，比如`scoop install xxx -s`即可，不放心的话可以到官网校验，或者根据仓库根路径的app-contributor-list.csv到相应的仓库提交issues

## 感谢

- [scoop-directory](https://github.com/rasa/scoop-directory)

## 合并仓库列表

- kkzzhizhou/scoop-zapps
- HCLonely/my-scoop-bucket
- Weidows-projects/scoop-3rd
- SayCV/scoop-cvp
- ScoopInstaller/PHP
- sliots/ScoopBucket
- ScoopInstaller/Extras
- chawyehsu/dorado
- matthewjberger/scoop-nerd-fonts
- Scoopforge/Extras-CN
- Calinou/scoop-games
- ScoopInstaller/Java
- ScoopInstaller/Versions
- TheRandomLabs/Scoop-Spotify
- borger/scoop-galaxy-integrations
- TheCjw/scoop-retools
- kodybrown/scoop-nirsoft
- ScoopInstaller/Nirsoft
- TheRandomLabs/scoop-nonportable
- littleli/scoop-clojure
- scoopcn/scoopcn
- ScoopInstaller/Nonportable
- kkzzhizhou/scoop-zapps
- rasa/scoops
- Paxxs/Cluttered-bucket
- kidonng/sushi
- ACooper81/scoop-apps
- KNOXDEV/wsl
- TLDRO/scoop-security
- cderv/r-bucket
- echoiron/echo-scoop
- ScoopInstaller/PHP
- hermanjustnu/scoop-emulators
- dodorz/scoop
- niheaven/scoop-sysinternals
- couleur-tweak-tips/utils
- borger/scoop-emulators
- ViCrack/scoop-bucket
- akirco/aki-apps
- kiennq/scoop-misc
- wangzq/scoop-bucket
- everyx/scoop-bucket
- cmontage/scoopbucket-third
- Qv2ray/mochi
- TheRandomLabs/Scoop-Bucket
- DoveBoy/Apps
- zhoujin7/tomato
- wzv5/ScoopBucket
- charmbracelet/scoop-bucket
- EFLKumo/jam
- amorphobia/siku
- TheRandomLabs/Scoop-Python
- hu3rror/scoop-muggle
- jonz94/scoop-sarasa-nerd-fonts
- NyaMisty/scoop_bucket_misty
- naderi/scoop-bucket
- noql-net/scoop
- abgox/abgo_bucket
- kengwang/scoop-ctftools-bucket
- WinApps-share/WinApps-bucket
- aliesbelik/poldi
- ygguorun/scoop-bucket
- asimov-platform/scoop-bucket
- brian6932/dank-scoop
- batkiz/backit
- ChungZH/peach
- liaoya/scoop-bucket
- Velgus/Scoop-Portapps
- AStupidBear/scoop-bear
- SayCV/scoop-cvp
- seumsc/scoop-seu
- Small-Ku/turbo-bucket
- TianXiaTech/scoop-txt
- Weidows-projects/scoop-3rd
- starise/Scoop-Confetti
- Darkatse/Scoop-Darkatse
- iquiw/scoop-bucket
- 42wim/scoop-bucket
- Scoopforge/Extras-Plus
- babo4d/scoop-xrtools
- jfut/scoop-jfut
- aoisummer/scoop-bucket
- cc713/ownscoop
- starise/Scoop-Gaming
- mo-san/scoop-bucket
- AkariiinMKII/Scoop4kariiin
- rivy/scoop-bucket
- Toddli468/Pentest-Scoop-Bucket
- HUMORCE/nuke
- littleli/Scoop-littleli
- littleli/Scoop-AtariEmulators
- Deide/deide-bucket
- typst-community/scoop-bucket
- natecohen/scoop-av
- KnotUntied/scoop-fonts
- beer-psi/scoop-bucket
- jingyu9575/scoop-jingyu9575
- Darkatse/Scoop-KanColle
- ChinLong/scoop-customize
- yuusakuri/scoop-bucket
- MCOfficer/scoop-bucket
- Rinkerbel/scooped
- AntonOks/scoop-aoks
- ShuguangSun/sgs-scoop-bucket
- windedge/ladle-bucket
- maboloshi/scoop-private
- The-Simples/scoop-minecraft
- younger-1/scoop-it
- WiiDatabase/scoop-bucket
- p8rdev/scoop-portableapps
- yuanying1199/scoopbucket
