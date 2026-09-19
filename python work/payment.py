import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from fontTools import subset

#4 payment table
payment_raw = pd.read_csv("C:/Users/pwnyd/Desktop/It Saas_raw/raw_payments.csv")
print(payment_raw)

# 1 remove duplicate payment_ID
payment_raw = payment_raw.drop_duplicates(subset=["Payment_ID"],keep="first")

#2 Clean Amount_USD
payment_raw["Amount_USD"] = (payment_raw["Amount_USD"].astype(str).str.replace("$","",regex=False).str.strip())
payment_raw["Amount_USD"] = pd.to_numeric(payment_raw["Amount_USD"],errors="coerce")
payment_raw["Amount_USD"] = payment_raw["Amount_USD"].abs().fillna(0.0)

# 3 Standardlize Status names
status_mapping = {
    "success":"Success",
    "Success":"Success",
    "SUCCESS":"Success",
    "FAILED":"Failed",
    "Failed":"Failed",
    "failed":"Failed",
    "Paid":"Success",
    "COMPLETED":"Success",
    "declined":"Failed",
    "ERROR":"Failed",
    "Canceled":"Failed",
    "Refunded":"Refunded",
    "refunded":"Refunded",
    "REFUND":"Refunded",
    "chargeback":"Refunded"
}
payment_raw["Status"] = (payment_raw["Status"].astype(str).str.strip().map(status_mapping).fillna("Failed"))

#4 standardize payment_date to YYYY-MM-DD
payment_raw["Payment_Date"] = pd.to_datetime(payment_raw["Payment_Date"],format = "mixed",errors="coerce").dt.strftime("%Y-%m-%d")

#5 save file
payment_raw.to_csv("payment_clean.csv",index=False)

