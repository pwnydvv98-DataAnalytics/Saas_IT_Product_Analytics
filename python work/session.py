import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from fontTools import subset

#3 Sessions Table cleaning

df_session = pd.read_csv("C:/Users/pwnyd/Desktop/It Saas_raw/raw_sessions.csv")

# 1 remove Duplicate Session_ID
df_session = df_session.drop_duplicates(subset=["Session_ID"],keep="first")

#2 Fix Duration : convert Negative values to positive
df_session ["Duration_Seconds"] = df_session["Duration_Seconds"].abs()
# fill missing duration with median
median_duration = df_session["Duration_Seconds"].median()
df_session["Duration_Seconds"] = df_session["Duration_Seconds"].fillna(median_duration)

# 3 Remove bot outlier sessions (impossible page views)
df_session = df_session[df_session["Pages_Viewed"]<9999]

#4 Standardlize campaign_ID attribution Strings
df_session["Campaign_ID"] = df_session["Campaign_ID"].fillna("Direct_Organic")
df_session["Campaign_ID"] = df_session["Campaign_ID"].replace({"organic":"Direct_Organic","direct_organic":"Direct_Organic"})
df_session["Campaign_ID"] = df_session["Campaign_ID"].str.upper()

# 5 standardlize Date format YYYY-MM-DD
df_session["Session_Date"] = pd.to_datetime(df_session["Session_Date"],format = "mixed",errors="coerce").dt.strftime("%Y-%m-%d")

#6 save the clean table
df_session.to_csv("sessions_clean.csv", index = False)

