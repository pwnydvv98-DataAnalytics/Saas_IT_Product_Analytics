import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from fontTools import subset

#6 support_ticket_raw table
support_raw = pd.read_csv("C:/Users/pwnyd/Desktop/It Saas_raw/raw_support_tickets.csv")

#1 remove duplicate ticket_id
support_raw = support_raw.drop_duplicates(subset=["Ticket_ID"],keep="first")

#2 standardize priority column values
priority_mapping = {
    "Low":"Low",
    "low":"Low",
    "LOW":"Low",
    "P3":"Low",
    "MEDIUM":"Medium",
    "Medium":"Medium",
    "P2":"Medium",
    "medium":"Medium",
    "HIGH":"High",
    "High":"High",
    "high":"High",
    "P1":"High",
    "Critical":"Critical",
    "critical":"Critical",
    "CRITICAL":"Critical",
    "P0":"Critical",
    "URGENT":"Critical",
}
support_raw["Priority"] = (support_raw["Priority"].astype(str).str.strip().map(priority_mapping).fillna("Low"))

#3 standardize Status column
status_mapping={
    "Resolved":"Resolved",
    "resolved":"Resolved",
    "Open":"Open",
    "open":"Open",
}
support_raw["Status"] = (support_raw["Status"].astype(str).str.strip().map(status_mapping).fillna("Open"))

#4 Standardize date
support_raw["Created_Date"] = pd.to_datetime(support_raw["Created_Date"],format= "mixed",errors= "coerce" )
support_raw["Resolved_Date"] = pd.to_datetime(support_raw["Resolved_Date"],format="mixed",errors="coerce")
invalid_res_mask =  support_raw["Resolved_Date"] < support_raw["Created_Date"]
support_raw.loc[invalid_res_mask,"Resolved_Date"] = pd.NaT
support_raw["Created_Date"] = support_raw["Created_Date"].dt.strftime("%Y-%m-%d")
support_raw["Resolved_Date"] = support_raw["Resolved_Date"].dt.strftime("%Y-%m-%d")

#5 Save file
support_raw.to_csv("support_clean.csv",index=False)
