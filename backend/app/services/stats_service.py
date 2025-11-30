import io
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from sqlalchemy.orm import Session
from app.models.water_log import WaterLog
from datetime import datetime, timedelta
from sqlalchemy import func

class StatsService:
    def __init__(self, db: Session):
        self.db = db

    def generate_day_heatmap(self, user_id: int) -> bytes:
        # Fetch data for today
        today = datetime.now().date()
        logs = self.db.query(WaterLog).filter(
            WaterLog.user_id == user_id,
            func.date(WaterLog.timestamp) == today
        ).all()

        # Process data
        data = {'Hour': [], 'Amount': []}
        for log in logs:
            data['Hour'].append(log.timestamp.hour)
            data['Amount'].append(log.amount_ml)
        
        df = pd.DataFrame(data)
        if df.empty:
            df = pd.DataFrame({'Hour': range(24), 'Amount': [0]*24})
        else:
            df = df.groupby('Hour')['Amount'].sum().reindex(range(24), fill_value=0).reset_index()

        # Generate Plot
        plt.figure(figsize=(10, 6))
        sns.set_theme(style="whitegrid")
        sns.barplot(x='Hour', y='Amount', data=df, color='indigo')
        plt.title("Today's Hourly Intake", fontsize=16, color='navy')
        plt.xlabel("Hour of Day", fontsize=12)
        plt.ylabel("Amount (ml)", fontsize=12)
        plt.xticks(rotation=45)
        plt.tight_layout()

        # Save to buffer
        buf = io.BytesIO()
        plt.savefig(buf, format='png')
        buf.seek(0)
        plt.close()
        return buf.getvalue()

    def generate_week_heatmap(self, user_id: int) -> bytes:
        # Fetch data for last 7 days
        today = datetime.now().date()
        week_ago = today - timedelta(days=6)
        logs = self.db.query(WaterLog).filter(
            WaterLog.user_id == user_id,
            func.date(WaterLog.timestamp) >= week_ago
        ).all()

        data = {'Date': [], 'Amount': []}
        for log in logs:
            data['Date'].append(log.timestamp.strftime('%Y-%m-%d'))
            data['Amount'].append(log.amount_ml)
        
        df = pd.DataFrame(data)
        # Ensure all days are present
        all_days = [(week_ago + timedelta(days=i)).strftime('%Y-%m-%d') for i in range(7)]
        if df.empty:
             df = pd.DataFrame({'Date': all_days, 'Amount': [0]*7})
        else:
            df = df.groupby('Date')['Amount'].sum().reindex(all_days, fill_value=0).reset_index()

        # Generate Plot
        plt.figure(figsize=(10, 6))
        sns.set_theme(style="whitegrid")
        sns.barplot(x='Date', y='Amount', data=df, color='indigo')
        plt.title("Weekly Intake", fontsize=16, color='navy')
        plt.xlabel("Date", fontsize=12)
        plt.ylabel("Amount (ml)", fontsize=12)
        plt.xticks(rotation=45)
        plt.tight_layout()

        buf = io.BytesIO()
        plt.savefig(buf, format='png')
        buf.seek(0)
        plt.close()
        return buf.getvalue()

    def generate_month_heatmap(self, user_id: int) -> bytes:
        # Fetch data for last 30 days
        today = datetime.now().date()
        month_ago = today - timedelta(days=29)
        logs = self.db.query(WaterLog).filter(
            WaterLog.user_id == user_id,
            func.date(WaterLog.timestamp) >= month_ago
        ).all()

        data = {'Date': [], 'Amount': []}
        for log in logs:
            data['Date'].append(log.timestamp.strftime('%Y-%m-%d'))
            data['Amount'].append(log.amount)
        
        df = pd.DataFrame(data)
        all_days = [(month_ago + timedelta(days=i)).strftime('%Y-%m-%d') for i in range(30)]
        
        if df.empty:
             df = pd.DataFrame({'Date': all_days, 'Amount': [0]*30})
        else:
            df = df.groupby('Date')['Amount'].sum().reindex(all_days, fill_value=0).reset_index()

        # Generate Plot
        plt.figure(figsize=(12, 6))
        sns.set_theme(style="whitegrid")
        sns.lineplot(x='Date', y='Amount', data=df, color='indigo', linewidth=2.5)
        plt.title("Monthly Intake Trend", fontsize=16, color='navy')
        plt.xlabel("Date", fontsize=12)
        plt.ylabel("Amount (ml)", fontsize=12)
        plt.xticks(rotation=90)
        plt.tight_layout()

        buf = io.BytesIO()
        plt.savefig(buf, format='png')
        buf.seek(0)
        plt.close()
        return buf.getvalue()
# Reload trigger
