<img src="https://repository-images.githubusercontent.com/11407242/86598c80-80ab-11ea-95a2-df46cca01e67">

---

# Ham-fisted
데이터 분석 프로젝트 폴더 구조 자동 생성 프로그램

## 쿠키커터 폴더 아키텍쳐
```
   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
   ┃     Folder Architecture       ┃
   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
      ├── data                ← ❌gitignore
      ├── libs                ← ㅇㅇ
      │   ├── __init__.py  
      │   ├── dataread.py
      ├── notebooks           ← Jupyter notebooks.
      │   ├── eda_template_ver0.ipynb
      │   ├── connectdb.py    
      ├── result              ← ㅇㅇ
      │   ├── chart 
      │   ├── txt
      ├── requirements.txt    ← The requirements file for reproducing the analysis environment, e.g. generated with `pip freeze > requirements.txt`
      ├── setup.py            ← makes project pip installable (pip install -e .) so src can be imported
      └── .gitignore        
```


## How To Use 

### (1)Alias 설정하지 않았을때
```zsh
$> cd "where-you-want"
$> git clone https://github.com/LS-ELLO/Ham-fisted
$> cd Ham-fisted

$> bash make.sh [where-you-want] [your-project-name]
ex) $> bash make.sh . my_project

```

### (2)Alias 설정했을때

```zsh
$> cd "where-you-want"
$> git clone https://github.com/LS-ELLO/Ham-fisted
$> cd Ham-fisted

$> cookie [where-you-want] [your-project-name]
ex) $> cookie . my_project

```

## Windows버전 쿠키커터: Alias 설정하기 (git-bash)
[참조](https://dev.to/mhjaafar/git-bash-on-windows-adding-a-permanent-alias-198g) <br>
1. `C:/Program Files/Git/etc/profile.d/aliases.sh` 파일을 관리자 권한으로 Text Editor에 실행시킵니다. <br>
2. 다음의 명령어를 추가합니다. <br>
    `alias cookie='bash make.sh의 상대경로'` <br>
    ex) `alias cookie='bash D:/Ham-fisted/windows/make.sh'`
    
    ***(aliases.sh)***
    ```sh
    # Some good standards, which are not used if the user
    # creates his/her own .bashrc/.bash_profile

    # --show-control-chars: help showing Korean or accented characters
    alias ls='ls -F --color=auto --show-control-chars'
    alias ll='ls -l'
    alias cookie='bash [where-your-make.sh]'

    case "$TERM" in
    ...
    ```
## Mac버전 쿠키커터: Alias 설정하기
```sh
echo 'alias cookie="bash [각자 컴퓨터의 상대경로/make.sh]"' >> ~/.zshrc
ex) echo 'alias cookie="bash /Users/ympark4/Desktop/Project/Test/Ham-fisted/mac/make.sh"' >> ~/.zshrc
```
[맥 파일경로 확인법](https://yangfra.tistory.com/11)을 참고하여, 각자 mac폴더안의 make.sh 파일의 경로를 확인하여 zshrc에 넣어주시면 됩니다. <br><br>

<br>
위와 같이 설정하면 cookie 명령어로 프로젝트를 생성할 수 있게 됩니다. <br>
