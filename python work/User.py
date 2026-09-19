import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from fontTools import subset

#
#1 User Table Clean

#1 User csv files
df_users = pd.read_csv("C:/Users/pwnyd/Desktop/It Saas_raw/raw_users.csv")
print(df_users.dtypes)
print(f"Starting row count:{len(df_users)}")

#2 Remove Duplicate User_ID
df_users = df_users.drop_duplicates(subset=['User_ID'], keep='first')
print(f"Row count after deduplication:{len(df_users)}")

#3 Clean up Plan Names using dictionary map
plan_mapping = {
    "Free_Tier":"Free_Tier",
    "free_tier":"Free_Tier",
    "FREE_TIER":"Free_Tier",
    " Free_Tier":"Free_Tier",
    "STARTER":"Starter",
    "starter":"Starter",
    " Starter":"Starter",
    " starter":"Starter",
    "Starter_plan":"Starter",
    "Profession":"Profession",
    "profession":"Profession",
    "PROFESSION":"Profession",
    " Profession":"Profession",
    "PRO":"Profession",
    "Pro":"Profession",
    "Enterprise":"Enterprise",
    "enterprise":"Enterprise",
    " Enterprise":"Enterprise",
    "ent":"Enterprise",
    "ENT":"Enterprise",
}
df_users["Plan"] = (df_users["Plan"].astype(str).str.strip().map(plan_mapping).fillna("Free_Tier"))

#4 Clean up Country_Name
Country_Mapping = {
    "Japan":"Japan",
    "japan":"Japan",
    " Japan" : "Japan",
    "JP" : "Japan",
    "JAPAN" : "Japan",
    "United States":"United States",
    "united states":"United States",
    " United States" : "United States",
    "USA":"United States",
    "US":"United States",
    "U.S.A":"United States",
    "Germany":"Germany",
    "germany":"Germany",
    "DE":"Germany",
    "India":"India",
    "india":"India",
    " India" : "India",
    "INDIA":"India",
    "United Kingdom":"United Kingdom",
    "UK":"United Kingdom",
    " UK":"United Kingdom",
    "uk":"United Kingdom",
    "Singapore":"Singapore",
    "SINGAPORE":"Singapore",
    " Singapore" : "Singapore",
    "SG":"Singapore",
}
df_users["Country"] = (df_users["Country"].astype(str).str.strip().map(Country_Mapping))

#5 Standardize mixed date string to YYYY-MM-DD
df_users["Signup_Date"]= pd.to_datetime(df_users["Signup_Date"],format ="mixed",errors="coerce")
print(df_users["Signup_Date"].min())
df_users["Signup_Date"] = df_users["Signup_Date"].fillna(pd.Timestamp("2023-01-01"))
df_users["Signup_Date"] = df_users["Signup_Date"].dt.strftime("%Y-%m-%d")

#6 Save clean file
df_users.to_csv("users_clean.csv", index=False)
print("user_clean.csv successfully created")
