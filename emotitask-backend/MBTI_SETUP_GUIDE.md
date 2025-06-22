# MBTI Personality System Setup Guide

This guide will help you set up the MBTI (Myers-Briggs Type Indicator) personality system for EmotiTask, which provides personalized AI chat experiences based on user personality types.

## 🎯 Overview

The MBTI system consists of:
- **Questions**: 10 personality assessment questions
- **Answers**: 4 answer choices per question (40 total)
- **Personality Types**: 16 MBTI personality types (INTJ, ENFP, etc.)
- **Chat Styles**: AI chat configurations for each personality type

## 🚀 Setup Instructions

### Step 1: Install Dependencies
```bash
cd emotitask-backend
pip install -r requirements.txt
```

### Step 2: Configure Environment
Make sure your `.env` file has Supabase database credentials.

### Step 3: Run Setup Script
```bash
python setup_mbti_tables.py
```

### Step 4: Start the API Server
```bash
python run.py
```

### Step 5: Test the MBTI Endpoints
```bash
python test_mbti_api.py
```

## 📡 API Endpoints

- GET /api/v1/mbti/questions - Get all questions with answers
- GET /api/v1/mbti/personality-types - Get all personality types
- GET /api/v1/mbti/personality-types/{persona_id} - Get specific type
- GET /api/v1/mbti/chat-styles - Get all chat styles
- POST /api/v1/mbti/assess - Submit assessment answers

**🎉 Your MBTI personality system is now ready to make EmotiTask truly personalized!**
