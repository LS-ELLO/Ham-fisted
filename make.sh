#!/usr/bin/env bash

## (예시)실행 명령어: bash make.sh . my_project
## (예시)실행 명령어 (alias설정시): cookie . my_project 

# don't overwrite files.
set -o noclobber
echo "[msg] **Don't overwrite files**"

# Exit if no arguments were provided.
# $# : 스크립트에 넘겨진 인자의 개수
# ex) ./test.sh a1 a2 a3 a4 이면, $# 의 값은 4

#echo $#
[ $# -lt 1 ] && { echo "Usage: $0 [target directory] [project name]"; exit 1; }

# the first argument passed into the script should be the dir
# where you want the folder structure setup

echo "[msg] Setting up... folder structure in $1"

if [ ! -d "$1" ]; then # -d FILE : FILE이 디렉토리 이면 참(true)
    mkdir $1
fi # end if

cd $1
mkdir $2

cd $2
mkdir data notebook libs result
touch requirements.txt setup.py

cat > LICENSE << EOF
EOF

cat > .gitignore << EOF

# Mac OS-specific storage files
.DS_Store

# Visual Studio Code configurations
.vscode/

# Data
data/
EOF

cd ./data
echo "Data directory for storing fixed data sets" > README.md
touch .gitkeep

cd ../result
echo "Result" > README.md
mkdir chart txt
cd ./chart 
echo "결과파일 (차트)" > README.md
cd ../txt 
echo "결과파일 (문서)" > README.md

cd ../

cd ../notebook 
cat > connectdb.py << EOF
# 사내 데이터포털 DB 접속방법
#%%

import pyodbc
import pandas as pd


## DataPortalDB Class
class DataPortalDB:
    def __init__(self, host, port, db, user, pwd) -> None:
        self.cnxn = None
        self.cursor = None
        self.init(host, port, db, user, pwd)

    def __enter__(self):
        return self

    def excute(self, query):
        self.cursor.excute(query)

    def commit(self):
        self.cnxn.commit()

    def fetchall(self):
        return self.cursor.fetchall()

    def read_sql(self, query):
        return pd.read_sql(query, self.cnxn)

    def init(self, host, port, db, user, pwd):
        self.cnxn = pyodbc.connect(
            "DRIVER={ODBC Driver 18 for SQL Server};SERVER="
            + host
            + ";uid="
            + user
            + ";pwd="
            + pwd
            + ";DATABASE="
            + db
            + ";TrustServerCertificate=yes;"
        )
        self.cursor = self.cnxn.cursor()
        self.cnxn.setencoding("UTF8")

    def close(self):
        self.cnxn.close()
        self.cursor = None

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close


# 사용방법
## DataLake 정보
server = "synw-datawarehouse-prod-001.sql.azuresynapse.net"
database = "syndpdatawarehouse"
username = "bi_analy_Viewer"
password = "Wels@456123"
driver = "{ODBC Driver 18 for SQL Server}"

## 쿼리(예시)
query = "select * from ERP.EXT_ERP_CST_View_Internal_Order_COGS"
# query = "select * from ERP.EXT_ERP_CST_View_Mass_Revenue_COGS"

## 실사용
db_connector = DataPortalDB(
    host=server, port=None, db=database, user=username, pwd=password
)
df:pd.DataFrame = db_connector.read_sql(query)
# %%
EOF

cd ../libs
echo "Util libraries" > README.md
cat > __init__.py << EOF
EOF

cat > dataread.py << EOF 
import glob
from dataclasses import dataclass, field
from io import StringIO
from pathlib import Path
from typing import List

import pandas as pd
import pyodbc
from azure.storage.blob import BlockBlobService, PublicAccess
from tqdm import tqdm


# 로컬 폴더
@dataclass
class LocalDB:
    """로컬 폴더에서 데이터를 읽어오는 클래스이다.

    Returns:
        file_list : list - 데이터 파일 목록
        df : dataframe - 데이터
    """

    file_list: List[int] = field(default_factory=list)
    df = pd.DataFrame()

    def __post_init__(self):
        None

    def get_file_list(self, file_type='*.csv'):
        """데이터 폴더에서 csv 파일 목록 가져오기

        Args:
            file_type (str, optional): 파일 확장자. Defaults to '*.csv'.

        Returns:
            self.file_list: csv 형식 파일 목록
        """

        path = "/".join(['./data', file_type])
        self.file_list = glob.glob(path)
        return self

    def select_read_file(self, letter: str):
        """사용자가 등록하여 불러온 동일 확장자 파일 중 일부만 선택하고 싶을 떄
           파일 이름에 특정 문자를 검색하여 가져오는 방식

        Args:
            letter (str): 파일 이름에 포함된 문자
        """
        self.file_list = [s for s in self.file_list if letter in s]

    def __read_csv(self, name: str, dtypes: dict, concode="euc-kr"):
        """
        CSV 단일 파일 읽어오기,
        """

        df_tmp_raw = pd.read_csv(name, dtype=dtypes, encoding=concode, low_memory=False)
        return df_tmp_raw

    def __read_excel(self):
        """
        엑셀 파일 불러오기
        """

    def read_csv_types(self, dtypes={}):
        """CSV 파일 여럿 불러 오기
        todo read_csv. read_excel - 함수 선택가능하도록 수정 필요

        Args:
            dtypes (dict, optional): 여러 컬럼 중 숫자와 문자가 포함된 경우 형식을 강제 지정하기. Defaults to {}.

        Returns:
            df: dataframe
        """
        raw_df = pd.DataFrame()
        for csv_file in tqdm(self.file_list, desc="Raw 데이터 불러오기"):
            try:
                tmp = self.__read_csv(csv_file, dtypes)
            except UnicodeDecodeError:
                try:
                    tmp = self.__read_csv(csv_file, dtypes, "utf-8", )
                except UnicodeDecodeError:
                    tmp = self.__read_csv(csv_file, dtypes, "cp949", )
            raw_df = pd.concat([raw_df, tmp], axis=0)
        self.df = raw_df.reset_index(drop=True)

        return self


# 사내 데이터포털 DB 접속방법
@dataclass
class DataPortalDB:
    SERVER = "synw-datawarehouse-prod-001.sql.azuresynapse.net"
    DATABASE = "syndpdatawarehouse"
    USERNAME = "bi_analy_Viewer"
    PASSWORD = "Wels@456123"

    df = pd.DataFrame()

    def __post_init__(self):
        self.cnxn = None
        self.cursor = None

    def __enter__(self):
        return self

    def excute(self, query):
        self.cursor.excute(query)

    def commit(self):
        self.cnxn.commit()

    def fetchall(self):
        return self.cursor.fetchall()

    def read_sql(self, query):
        self.df = pd.read_sql(query, self.cnxn)

    def init(self):
        self.cnxn = pyodbc.connect(
            "DRIVER={ODBC Driver 18 for SQL Server};SERVER="
            + self.SERVER
            + ";uid="
            + self.USERNAME
            + ";pwd="
            + self.PASSWORD
            + ";DATABASE="
            + self.DATABASE
            + ";TrustServerCertificate=yes;"
        )
        self.cursor = self.cnxn.cursor()
        self.cnxn.setencoding("UTF8")

    def close(self):
        self.cnxn.close()
        self.cursor = None

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close


# Azure Blob Storage
@dataclass
class Azureblobstorage:
    ACCOUNT_NAME = 'dlscertificationsstudy'
    ACCOUNT_KEY = '6Khew8/1xcCK8IYh/UEmI9627kT0YfJtUx48X1u3r/MaJZQSSU17P0I51aH6hqN+zV3TFaEp0+5p+AStGxFXRg=='
    CONTAINER_NAME = 'ls-eda-data'
    blob_service_client = None

    file_list: List[int] = field(default_factory=list)
    df = pd.DataFrame()

    def __post_init__(self):
        """Azure Blob Storage 사용을 위한 초기 세팅
        """
        # Create the BlockBlobService that is used to call the Blob service for the storage account
        self.blob_service_client = BlockBlobService(account_name=self.ACCOUNT_NAME, account_key=self.ACCOUNT_KEY)
        # Create a container called 'quickstartblobs'.
        self.blob_service_client.create_container(self.CONTAINER_NAME)
        # Set the permission so the blobs are public.
        self.blob_service_client.set_container_acl(self.CONTAINER_NAME, public_access=PublicAccess.Container)

    def get_file_list(self, folder_name='raw'):
        """Azure Blob Storage 데이터 폴더 중 원하는 폴더의 파일 리스트만 가져오기 

        Args:
            folder_name (str, optional): 폴더 이름. Defaults to 'raw'.

        Returns:
            self.file_list (list) : 폴더 내 csv 파일 만
        """

        generator = self.blob_service_client.list_blobs(self.CONTAINER_NAME)
        for blob in generator:
            self.file_list.append(blob.name) if folder_name in blob.name else None
        return self

    def select_read_file(self, letter: str):
        """사용자가 등록하여 불러온 동일 확장자 파일 중 일부만 선택하고 싶을 떄
           파일 이름에 특정 문자를 검색하여 가져오는 방식

        Args:
            letter (str): 파일 이름에 포함된 문자
        """
        self.file_list = [s for s in self.file_list if letter in s]
        return self

    def __read_csv(self, name: str, dtypes: dict, concode="euc-kr"):
        """
        CSV 단일 파일 읽어오기,
        """
        blobstring = self.blob_service_client.get_blob_to_text(self.CONTAINER_NAME, name, encoding='euc-kr')
        df_tmp_raw = pd.read_csv(StringIO(blobstring.content), dtype=dtypes)

        return df_tmp_raw

    def read_csv_types(self, dtypes={}):
        """CSV 파일 여럿 불러 오기
        todo read_csv. read_excel - 함수 선택가능하도록 수정 필요

        Args:
            dtypes (dict, optional): 여러 컬럼 중 숫자와 문자가 포함된 경우 형식을 강제 지정하기. Defaults to {}.

        Returns:
            df: dataframe
        """

        raw_df = pd.DataFrame()
        for csv_file in tqdm(self.file_list, desc="Raw 데이터 불러오기"):
            try:
                tmp = self.__read_csv(csv_file, dtypes)
            except UnicodeDecodeError:
                try:
                    tmp = self.__read_csv(csv_file, dtypes, "utf-8", )
                except UnicodeDecodeError:
                    tmp = self.__read_csv(csv_file, dtypes, "cp949", )
            raw_df = pd.concat([raw_df, tmp], axis=0)
        self.df = raw_df.reset_index(drop=True)

        return self
EOF 

cd ../../


# 메인 README 생성
cat > README.md << EOF
#cookie-cutter-for-your-project
프로젝트 폴더 구성을 세팅하기 위하여 cookie cutter (aka. project template)를 사용합니다.
cookie cutter를 통해서 프로젝트를 구성하는데 표준의 폴더 구조를 쉽고 빠르게 설정할 수 있습니다.
EOF
echo "[msg] Top-level README.md created" # cmd 로그