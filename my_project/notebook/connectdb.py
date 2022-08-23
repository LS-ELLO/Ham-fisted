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
