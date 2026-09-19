import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from fontTools import subset

#5 Event table
event_raw = pd.read_csv("C:/Users/pwnyd/Desktop/It Saas_raw/raw_events.csv")

# 1 Remove Duplicate Event_ID
event_raw = event_raw.drop_duplicates(subset=["Event_ID"],keep = "first")

#2 standardize event_type
event_type_mapping = {
    "login":"Login",
    "user_login":"Login",
    "LOGIN":"Login",
    "dashboard_render":"Dashboard_Render",
    "DASHBOARD_VIEW":"Dashboard_View",
    "report_exported":"Report_Exported",
    "csv_export":"Report_Exported",
    "EXPORT_REPORT":"Report_Exported",
    "filter_applied":"Filter_Applied",
    "FILTER_CLICK":"Filter_Applied",
    "FILTER_REPORT":"Filter_Applied",
    "query_executed":"Query_Executed",
    "sql_query_run":"Query_Executed",
    "webhook_triggered":"Webhook_Triggered",
    "api_webhook":"Webhook_Triggered",
    "ticket_submitted":"Ticket_Submitted",
    "support_ticket_created":"Ticket_Submitted",
    "invite_sent":"Invite_Sent",
    "team_invite":"Invite_Sent",
    "upgrade_clicked":"Upgrade_Clicked",
    "UPGRADE_CLICKED":"Upgrade_Clicked",
}
event_raw["Event_Type"] = (event_raw["Event_Type"].astype(str).str.strip().map(event_type_mapping))
event_raw["Event_Type"] = event_raw["Event_Type"].fillna("Login")

# 3 standardize Event_Date (YYYY_MM_DD)
event_raw["Event_Date"] = pd.to_datetime(event_raw["Event_Date"],format="mixed",errors="coerce").dt.strftime("%Y-%m-%d")

#4 convert Session_ID
event_raw["Session_ID"] = pd.to_numeric(event_raw["Session_ID"],errors="coerce").astype("Int64")

#5 save file
event_raw.to_csv("event_clean.csv",index=False)
print(event_raw)

