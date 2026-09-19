import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from fontTools import subset

#2 Raw_Subscriptions Table clean
df_subscription = pd.read_csv("C:/Users/pwnyd/Desktop/It Saas_raw/raw_subscriptions.csv")
print(f"row_count: {len(df_subscription):,}")

#1 deduplicate by subscription_ID
print(df_subscription.dtypes)
df_subscription = df_subscription.drop_duplicates(subset=['Subscription_ID'],keep='first')
print(f"row_count: {len(df_subscription):,}")

#2 Standardize plan names
plan_mapping = {
    "Free_Tier" : "Free_Tier",
    "free_tier" : "Free_Tier",
    "FREE TIER" : "Free_Tier",
    "FREE_TIER" : "Free_Tier",
    "Free": "Free_Tier",
    "Starter": "Starter",
    "starter" : "Starter",
    " starter" : "Starter",
    "STARTER" : "Starter",
    "Starter_Plan":"Starter",
    "Professional": "Professional",
    "professional" : "Professional",
    " Professional" : "Professional",
    "PROFESSIONAL" : "Professional",
    "ENTERPRISE" : "Enterprise",
    "enterprise" : "Enterprise",
    "Enterprise_Plan":"Enterprise",
    "Enterprise": "Enterprise",
    "Ent": "Enterprise",
    "ENT": "Enterprise",
}
df_subscription["Plan"] = df_subscription["Plan"].astype(str).str.strip().map(plan_mapping).fillna("Free_Tier")

#3 clean monthly_revenue
df_subscription["Monthly_Revenue"] = (
    df_subscription["Monthly_Revenue"].astype(str).str.replace("$","",regex=False)
    .str.replace("USD","",regex=False)
    .str.strip()
)
df_subscription["Monthly_Revenue"] = pd.to_numeric(df_subscription["Monthly_Revenue"],errors="coerce")
df_subscription["Monthly_Revenue"] = df_subscription["Monthly_Revenue"].abs().fillna(0.0)

#4 Standardize Dates & fix Chronology (End Date < Start Date)
start_dt = pd.to_datetime(df_subscription["Start_Date"],format = "mixed",errors="coerce")
end_dt = pd.to_datetime(df_subscription["End_Date"],format = "mixed",errors="coerce")
#if end date is earlier then start date
invalid_mask = end_dt < start_dt
end_dt.loc[invalid_mask] = pd.NaT
df_subscription["Start_Date"] = start_dt.dt.strftime("%Y-%m-%d")
df_subscription["End_Date"] = end_dt.dt.strftime("%Y-%m-%d")

# export cleaned file
df_subscription.to_csv("subscriptions_clean.csv",index=False)
