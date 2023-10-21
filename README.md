### CFwarp脚本相关说明请查看[甬哥博客](https://ygkkk.blogspot.com/2022/09/cfwarp-script.html)
### 相关说明及注意点请查看[warp系列视频说明](https://www.youtube.com/playlist?list=PLMgly2AulGG-WqPXPkHlqWVSfQ3XjHNw8)
------------------------------------------------------------------------------------------------------------------------------
#### vps一键脚本：
```
bash <(wget -qO- https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh 2> /dev/null)
```
或者
```
bash <(curl -Ls https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh)
```
----------------------------------------------------------------------------------------------------------------------

### 多平台优选WARP对端IP + 无限生成WARP-Wireguard配置 脚本
```
curl -sSL https://gitlab.com/rwkgyg/CFwarp/raw/main/point/endip.sh -o endip.sh && chmod +x endip.sh && ./endip.sh
```
-------------------------------------------------------------------------------------------------------------------------

#### 感谢WGCF源项目代码地址：https://github.com/ViRb3/wgcf
#### 感谢CoiaPrant，WARP-GO源项目代码地址：https://gitlab.com/ProjectWARP/warp-go
#### 相关功能参考来源： [P3terx](https://github.com/P3TERX/warp.sh)、[fscarmen](https://github.com/fscarmen/warp)、[热心的CF网友](https://github.com/badafans)提供的warp endpoint优选IP脚本及注册程序
