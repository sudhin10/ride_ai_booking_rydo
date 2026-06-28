@echo off
REM Rydo — one-terminal launcher (Windows).
REM Opens backend + ML in background windows, runs Flutter in this one.
echo ==^> Starting backend (http://localhost:5000)
start "Rydo Backend" cmd /c "cd backend && npm install && npm run seed && npm run dev"

echo ==^> Starting ML service (http://localhost:8000) [optional]
start "Rydo ML" cmd /c "cd ml-service && pip install -r requirements.txt && uvicorn app:app --port 8000"

timeout /t 6 >nul

echo ==^> Launching Flutter app
cd frontend
call flutter pub get
call flutter create . --platforms=android,web,windows >nul 2>&1
call flutter run -d chrome
